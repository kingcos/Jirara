//
//  SendPreviewWindowController.swift
//  Jirara
//
//  Created by kingcos on 2018/6/27.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa
import WebKit

enum SummaryType {
    case `default`
    case categories
}

class SendPreviewWindowController: NSWindowController {

    @IBOutlet weak var webView: WKWebView!
    
    @IBOutlet weak var subjectTextField: NSTextField!
    @IBOutlet weak var emailToTextField: NSTextField!
    @IBOutlet weak var emailCcTextField: NSTextField!
    @IBOutlet weak var emailFromTextField: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var emailSendButton: NSButton!
    
    var type: SummaryType = .default
    var contentHTML: String?
    
    override var windowNibName: NSNib.Name? {
        return .SendPreviewWindowController
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.center()
        window?.makeKeyAndOrderFront(nil)
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        
        setupUI()
    }
    
    func setupUI() {
        emailToTextField.stringValue = UserDefaults.get(by: .emailTo)
        emailCcTextField.stringValue = UserDefaults.get(by: .emailCc)
        emailFromTextField.stringValue = UserDefaults.get(by: .emailAddress)
        emailFromTextField.isEditable = false
        
        emailSendButton.isEnabled = false
        progressIndicator.startAnimation(nil)
        
        if type == .default {
            MailUtil.send { subject, contentHTML in
                self.contentHTML = contentHTML
                
                self.subjectTextField.stringValue = subject
                self.webView.loadHTMLString(contentHTML, baseURL: nil)
                
                self.progressIndicator.stopAnimation(nil)
                self.progressIndicator.isHidden = true
                self.emailSendButton.isEnabled = true
            }
        } else {
            MailUtil.send(type) { subject, contentHTML in
                self.contentHTML = contentHTML
                
                self.subjectTextField.stringValue = subject
                self.webView.loadHTMLString(contentHTML, baseURL: nil)
                
                self.progressIndicator.stopAnimation(nil)
                self.progressIndicator.isHidden = true
                self.emailSendButton.isEnabled = true
            }
        }
    }
    
    @IBAction func clickOnSendButton(_ sender: NSButton) {
        subjectTextField.isEditable = false
        emailToTextField.isEditable = false
        emailCcTextField.isEditable = false
        
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(nil)
        
        emailSendButton.isEnabled = false
        
        let from = emailFromTextField.stringValue
        let to = emailToTextField.stringValue.split(separator: " ").map { String($0) }
        let cc = emailCcTextField.stringValue.split(separator: " ").map { String($0) }
        let subject = subjectTextField.stringValue
        let content = contentHTML ?? ""
        
        MailUtil().send(from, to, cc, subject, content) {
            self.progressIndicator.stopAnimation(nil)
            self.subjectTextField.isEditable = true
            self.emailToTextField.isEditable = true
            self.emailCcTextField.isEditable = true
            self.progressIndicator.isHidden = true
            self.emailSendButton.isEnabled = true
            
            NSAlert.show("Send successfully!", ["OK"])
        }
    }
}
