//
//  PreferencesWindowController.swift
//  Jirara
//
//  Created by kingcos on 2018/6/25.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

class PreferencesWindowController: NSWindowController {
    
    // Account
    // - AD
    @IBOutlet weak var accJiraDomainTextField: NSTextField!
    @IBOutlet weak var accUsernameTextField: NSTextField!
    @IBOutlet weak var accPasswordTextField: NSSecureTextField!
    // - E-mail
    @IBOutlet weak var accEmailSMTPTextField: NSTextField!
    @IBOutlet weak var accEmailAddressTextField: NSTextField!
    @IBOutlet weak var accEmailPasswordTextField: NSSecureTextField!
    @IBOutlet weak var accEmailPortTextField: NSTextField!
    @IBOutlet weak var accIsUniversalAccountSwitch: NSButton!
    @IBOutlet weak var accTestAndSaveButton: NSButton!
    @IBOutlet weak var accLoadingIndicator: NSProgressIndicator!
    
    // Send
    @IBOutlet weak var sendToTextField: NSTextField!
    @IBOutlet weak var sendCcTextField: NSTextField!
    @IBOutlet weak var scrumNameTextField: NSTextField!
    
    // Timer
    @IBOutlet weak var jiraRefreshTimerButton: NSButton!
    
    override var windowNibName: NSNib.Name? {
        return .PreferencesWindowController
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        
        // Show window at most front all the time
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        setupUI()
    }
    
    func setupUI() {
        // Account
        accJiraDomainTextField.stringValue = UserDefaults.get(by: .accountJiraDomain)
        accUsernameTextField.stringValue = UserDefaults.get(by: .accountUsername)
        accPasswordTextField.stringValue = UserDefaults.get(by: .accountPassword)
        
        accEmailSMTPTextField.stringValue = UserDefaults.get(by: .emailSMTP)
        accEmailAddressTextField.stringValue = UserDefaults.get(by: .emailAddress)
        accEmailPasswordTextField.stringValue = UserDefaults.get(by: .emailPassword)
        accEmailPortTextField.stringValue = UserDefaults.get(by: .emailPort)
        if UserDefaults.get(by: .emailAccountUniversalState) == "" {
            // 没有保存「AD 账户是否等同于邮件帐户」
            accEmailAddressTextField.isEnabled = false
            accEmailPasswordTextField.isEnabled = false
            accIsUniversalAccountSwitch.state = .on
        } else if UserDefaults.get(by: .emailAccountUniversalState) == "on"  {
            accEmailAddressTextField.isEnabled = false
            accEmailPasswordTextField.isEnabled = false
            accIsUniversalAccountSwitch.state = .on
        } else if UserDefaults.get(by: .emailAccountUniversalState) == "off"  {
            accEmailAddressTextField.isEnabled = true
            accEmailPasswordTextField.isEnabled = true
            accIsUniversalAccountSwitch.state = .off
        }
        
        // Send
        sendToTextField.stringValue = UserDefaults.get(by: .emailTo)
        sendCcTextField.stringValue = UserDefaults.get(by: .emailCc)
        scrumNameTextField.stringValue = UserDefaults.get(by: .scrumName)
        
        accLoadingIndicator.isHidden = true
        
        // Timer
        UserDefaults.save(jiraRefreshTimerButton.state == .on ? "on" : "off", for: .jiraTimerSwitch)
        jiraRefreshTimerButton.state = UserDefaults.get(by: .jiraTimerSwitch) == "on" ? .on : .off
    }
}

// MARK: Account
extension PreferencesWindowController {
    @IBAction func clickOnAccSaveButton(_ sender: NSButton) {
        accJiraDomainTextField.isEnabled = false
        accUsernameTextField.isEnabled = false
        accPasswordTextField.isEnabled = false
        
        accEmailSMTPTextField.isEnabled = false
        accEmailAddressTextField.isEnabled = false
        accEmailPasswordTextField.isEnabled = false
        accEmailPortTextField.isEnabled = false
        accIsUniversalAccountSwitch.isEnabled = false
        accTestAndSaveButton.isEnabled = false
        accLoadingIndicator.isHidden = false
        accLoadingIndicator.startAnimation(nil)
        
        // Save to UserDefaults
        UserDefaults.save(accJiraDomainTextField.stringValue, for: .accountJiraDomain)
        UserDefaults.save(accUsernameTextField.stringValue, for: .accountUsername)
        UserDefaults.save(accPasswordTextField.stringValue, for: .accountPassword)
        
        UserDefaults.save("Basic " + "\(accUsernameTextField.stringValue):\(accPasswordTextField.stringValue)".base64Encoded,
                          for: .accountAuth)
        
        // Save to UserDefaults
        UserDefaults.save(accEmailSMTPTextField.stringValue, for: .emailSMTP)
        UserDefaults.save(accEmailAddressTextField.stringValue, for: .emailAddress)
        UserDefaults.save(accEmailPasswordTextField.stringValue, for: .emailPassword)
        UserDefaults.save(accEmailPortTextField.stringValue, for: .emailPort)
        
        if accIsUniversalAccountSwitch.state == .off {
            UserDefaults.save("off", for: .emailAccountUniversalState)
        } else {
            accEmailAddressTextField.stringValue = accUsernameTextField.stringValue + "@mobike.com"
            accEmailPasswordTextField.stringValue = accPasswordTextField.stringValue
            UserDefaults.save("on", for: .emailAccountUniversalState)
        }
        
//        MainViewModel.fetchEngineer(UserDefaults.get(by: .accountUsername)) { engineer in
//            MailUtil().send(UserDefaults.get(by: .emailAddress),
//                            [UserDefaults.get(by: .emailAddress)],
//                            [UserDefaults.get(by: .emailAddress)],
//                            "Jirara 测试邮件",
//                            "请确保您能收到该邮件，以保证您能使用 Jirara 的周报系统。<br>by Jirara") { emailErrorMessage in
//                                let message = "Test Result "
//                                if let emailErrorMessage = emailErrorMessage {
//                                    if let jiraErrorMessage = jiraErrorMessage {
//                                        NSAlert.show(message + "FAILURE",
//                                                     ["I got it."],
//                                                     "Jira FAILURE: " + jiraErrorMessage + "\nE-mail FAILURE:" + emailErrorMessage)
//                                    } else {
//                                        NSAlert.show(message + "FAILURE",
//                                                     ["I got it."],
//                                                     "Jira SUCCESS!\nBut E-mail FAILURE:" + emailErrorMessage)
//                                    }
//                                } else {
//                                    if let jiraErrorMessage = jiraErrorMessage {
//                                        NSAlert.show(message + "FAILURE",
//                                                     ["I got it."],
//                                                     "E-mail SUCCESS!\nBut Jira FAILURE:" + jiraErrorMessage)
//                                    } else {
//                                        NSAlert.show(message + "SUCCESS",
//                                                     ["I got it."],
//                                                     "Jira & E-mail SUCCESS!")
//                                        MainViewModel.fetch(Constants.RapidViewName, false) {
//                                            MainViewModel.fetch(Constants.RapidViewName) {
//                                                NSUserNotification.send("Data has been updated!")
//                                            }
//                                        }
//                                    }
//                                }
//
//                                self.accJiraDomainTextField.isEnabled = true
//                                self.accUsernameTextField.isEnabled = true
//                                self.accPasswordTextField.isEnabled = true
//
//                                self.accEmailSMTPTextField.isEnabled = true
//                                self.accEmailAddressTextField.isEnabled = true
//                                self.accEmailPasswordTextField.isEnabled = true
//                                self.accEmailPortTextField.isEnabled = true
//                                self.accIsUniversalAccountSwitch.isEnabled = true
//                                self.accTestAndSaveButton.isEnabled = true
//                                self.accLoadingIndicator.isHidden = true
//                                self.accLoadingIndicator.stopAnimation(nil)
//            }
//        }
    }
    
    @IBAction func clickOnIsSameAsAD(_ sender: NSButton) {
        if sender.state == .on {
            accEmailAddressTextField.isEnabled = false
            accEmailPasswordTextField.isEnabled = false
        } else {
            accEmailAddressTextField.isEnabled = true
            accEmailPasswordTextField.isEnabled = true
        }
    }
}

// MARK: Send
extension PreferencesWindowController {
    @IBAction func clickOnSendSaveButton(_ sender: NSButton) {
        // Save to UserDefaults
        UserDefaults.save(sendToTextField.stringValue, for: .emailTo)
        UserDefaults.save(sendCcTextField.stringValue, for: .emailCc)
        UserDefaults.save(scrumNameTextField.stringValue, for: .scrumName)
        
        NSAlert.show("Saved", ["OK"])
    }
}

// MARK: Others
extension PreferencesWindowController {
    @IBAction func clickOnTimerSaveButton(_ sender: NSButton) {
        // Save to UserDefaults
        UserDefaults.save(jiraRefreshTimerButton.state == .on ? "on" : "off", for: .jiraTimerSwitch)
        
        // Start or cancel Timer
        if jiraRefreshTimerButton.state == .on {
            Timer.shared.cancle(.jiraRefresher)
            Timer.shared.scheduled(.jiraRefresher,
                                   60 * 30,
                                   DispatchQueue.global(),
                                   true) {
//                                                    MainViewModel.fetch(Constants.RapidViewName, false) { _ in
//                                                        MainViewModel.fetch(Constants.RapidViewName) {
////                                                            NSUserNotification.send("Finished refreshing!")
//                                                        }
//                                                    }
            }
        } else {
            Timer.shared.cancle(.jiraRefresher)
        }
        
        NSAlert.show("Saved", ["OK"])
    }
}
