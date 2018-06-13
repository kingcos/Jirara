//
//  LoginViewController.swift
//  Jirara
//
//  Created by kingcos on 2018/6/12.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

class LoginViewController: NSViewController {

    @IBOutlet weak var jiraDomainTextField: NSTextField!
    @IBOutlet weak var usernameTextField: NSTextField!
    @IBOutlet weak var passwordTextField: NSSecureTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func clickOnLoginButton(_ sender: NSButton) {
        guard let jiraDomain = jiraDomainTextField.cell?.title,
        let username = usernameTextField.cell?.title,
        let password = passwordTextField.cell?.title else { return }
        
        
    }
    
}
