//
//  LoginViewController.swift
//  Jirara
//
//  Created by kingcos on 2018/6/12.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa
import Alamofire

class LoginViewController: NSViewController {

    @IBOutlet weak var loginProgressIndicator: NSProgressIndicator!
    @IBOutlet weak var jiraDomainTextField: NSTextField!
    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    @IBOutlet weak var loginButton: NSButton!
    @IBOutlet weak var warningTextField: NSTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        reloadUI()
        
        warningTextField.isHidden = true
        
        jiraDomainTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        clickOnLoginButton(loginButton)
    }
    
    func reloadUI() {
        loginProgressIndicator.isHidden = true
        
        jiraDomainTextField.isEditable = true
        usernameTextField.isEditable = true
        passwordTextField.isEditable = true
        
        jiraDomainTextField.stringValue = UserDefaults.get(by: .accountJiraDomain)
        usernameTextField.stringValue = UserDefaults.get(by: .accountUsername)
        
        loginButton.isEnabled = !jiraDomainTextField.stringValue.isEmpty
                             && !usernameTextField.stringValue.isEmpty
                             && !passwordTextField.stringValue.isEmpty
    }
    
}

// MARK: IBAction
extension LoginViewController {
    @IBAction func clickOnLoginButton(_ sender: NSButton) {
        guard let jiraDomain = jiraDomainTextField.cell?.title,
            let username = usernameTextField.cell?.title,
            let password = passwordTextField.cell?.title else { return }
        
        // UI related
        loginProgressIndicator.isHidden = false
        loginProgressIndicator.startAnimation(nil)
        
        jiraDomainTextField.isEditable = false
        usernameTextField.isEditable = false
        passwordTextField.isEditable = false
        loginButton.isEnabled = false
        warningTextField.isHidden = true
        
        // Logic releated
        UserDefaults.save(jiraDomain, for: .accountJiraDomain)
        UserDefaults.save(username, for: .accountUsername)
        UserDefaults.save("Basic " + "\(username):\(password)".base64Encoded, for: .accountAuth)
        
        let url = JiraAPI.prefix.rawValue + jiraDomain + JiraAPI.myself.rawValue
        let headers = ["Authorization" : UserDefaults.get(by: .accountAuth)]
        
        Alamofire.request(url, headers: headers)
                 .responseData { response in
                    guard let statusCode = response.response?.statusCode else {
                        self.warningTextField.isHidden = false
                        self.warningTextField.stringValue = "[Error] The connection is broken! Please check your Jira domain, network or VPN."
                        self.reloadUI()
                        
                        return
                    }
                    
                    switch statusCode {
                    case 200:
                        guard let data = response.data,
                            let engineer = try? Engineer(JSONData: data) else {
                                fatalError("\(url) may be broken.")
                        }
                        
//                        UserDefaults.save(engineer.emailAddress, for: .email)
                        
                        MainViewModel.fetch { _, _ in
                            // Notify
                            NotificationCenter.default.post(name: .UpdatedRemoteData, object: nil)
                        }
                        
                        let storyboard = NSStoryboard(name: .init("Main"), bundle: nil)
                        let mainSplitWindowController = storyboard.instantiateController(withIdentifier: .init("MainWindowController")) as? NSWindowController
                        mainSplitWindowController?.showWindow(self)
                        self.view.window?.close()
                    case 401:
                        self.warningTextField.isHidden = false
                        self.warningTextField.stringValue = "[Error] You'd better to check your username or password!"
                        self.reloadUI()
                    case 403:
                        self.warningTextField.isHidden = false
                        self.warningTextField.stringValue = "[Error] You should sign out and sign in on the website! Then try it again."
                        self.reloadUI()
                    default:
                        self.warningTextField.isHidden = false
                        self.warningTextField.stringValue = "[Error] Unknown error!"
                        self.reloadUI()
                    }
        }
        
        
    }
}

extension LoginViewController: NSTextFieldDelegate {
    override func controlTextDidChange(_ obj: Notification) {
        if jiraDomainTextField.stringValue.isEmpty
        || usernameTextField.stringValue.isEmpty
        || passwordTextField.stringValue.isEmpty {
            loginButton.isEnabled = false
        } else {
            loginButton.isEnabled = true
        }
    }
}
