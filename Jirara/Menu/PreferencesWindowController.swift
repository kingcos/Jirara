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
    @IBOutlet weak var accJiraDomainTextField: NSTextField!
    @IBOutlet weak var accUsernameTextField: NSTextField!
    @IBOutlet weak var accPasswordTextField: NSSecureTextField!
    @IBOutlet weak var accEmailSMTPTextField: NSTextField!
    @IBOutlet weak var accEmailAddressTextField: NSTextField!
    @IBOutlet weak var accEmailPasswordTextField: NSSecureTextField!
    @IBOutlet weak var accEmailPortTextField: NSTextField!
    
    // Send
    @IBOutlet weak var sendToTextField: NSTextField!
    @IBOutlet weak var sendCCTextField: NSTextField!
    
    // Others
    
    
    
    override var windowNibName: NSNib.Name? {
        return .PreferencesWindowController
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        window?.center()
        window?.makeKeyAndOrderFront(nil)
    }
    
}

// MARK: Account
extension PreferencesWindowController {
    @IBAction func clickOnAccTestAndSaveButton(_ sender: NSButton) {
        // Save to UserDefaults
        UserDefaults.save(accJiraDomainTextField.stringValue, for: .accountJiraDomain)
        UserDefaults.save("Basic " + "\(accUsernameTextField.stringValue):\(accPasswordTextField.stringValue)".base64Encoded,
                          for: .userAuth)
    }
    
    @IBAction func clickOnEmailTestAndSaveButton(_ sender: NSButton) {
        // Save to UserDefaults
        UserDefaults.save(accEmailSMTPTextField.stringValue, for: .emailSMTP)
        UserDefaults.save(accEmailAddressTextField.stringValue, for: .emailAddress)
        UserDefaults.save(accEmailPasswordTextField.stringValue, for: .emailPassword)
        UserDefaults.save(accEmailPortTextField.stringValue, for: .emailPort)
    }
}

// MARK: Send
extension PreferencesWindowController {
    @IBAction func clickOnSendSaveButton(_ sender: NSButton) {
        let toArray = sendToTextField.stringValue.split(separator: " ").map { String($0) }
        let ccArray = sendCCTextField.stringValue.split(separator: " ").map { String($0) }
        
        // Save to UserDefaults
        UserDefaults.save(toArray, for: .emailTo)
        UserDefaults.save(ccArray, for: .emailCC)
    }
}

// MARK: Others
extension PreferencesWindowController {
    
}
