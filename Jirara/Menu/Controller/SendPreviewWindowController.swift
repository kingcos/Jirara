//
//  SendPreviewWindowController.swift
//  Jirara
//
//  Created by kingcos on 2018/6/27.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa
import Down
import SnapKit

enum SummaryType: String {
    case team = "团队周报"
    case individual = "个人周报"
}

class SendPreviewWindowController: NSWindowController {
    
    @IBOutlet weak var subjectTextField: NSTextField!
    @IBOutlet weak var emailToTextField: NSTextField!
    @IBOutlet weak var emailCcTextField: NSTextField!
    @IBOutlet weak var emailFromTextField: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var emailSendButton: NSButton!
    
    @IBOutlet weak var markdownTextView: NSTextView!
    @IBOutlet weak var markdownContainerView: NSView!
    
    @IBOutlet weak var downContainerView: NSView!
    var downView: DownView!
    
    @IBOutlet weak var downContainerWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var markdownContainerWidthConstraint: NSLayoutConstraint!
    
    var type: SummaryType = .team
    
    override var windowNibName: NSNib.Name? {
        return .SendPreviewWindowController
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        setupConstraints()
        setupDownView()
        setupMarkdownView()
        setupHeaderViews()
    }
    
    func setupConstraints() {
        if type == .individual {
            markdownContainerView.isHidden = false
            downContainerWidthConstraint = downContainerWidthConstraint.setMultiplier(0.5)
        } else {
            markdownContainerView.isHidden = true
            downContainerWidthConstraint = downContainerWidthConstraint.setMultiplier(1.0)
        }
    }
    
    func setupDownView() {
        try? downView = DownView(frame: downContainerView.bounds, markdownString: "")
        downContainerView.addSubview(downView)
        
        downView.snp.makeConstraints { maker in
            maker.top.equalTo(self.downContainerView.snp.top)
            maker.bottom.equalTo(self.downContainerView.snp.bottom)
            maker.left.equalTo(self.downContainerView.snp.left)
            maker.right.equalTo(self.downContainerView.snp.right)
        }
    }
    
    func setupMarkdownView() {
        markdownTextView.textContainerInset = NSSize.init(width: 10, height: 5)
        markdownTextView.delegate = self
    }
    
    func setupHeaderViews() {
        emailToTextField.stringValue = UserDefaults.get(by: .emailTo)
        emailCcTextField.stringValue = UserDefaults.get(by: .emailCc)
        emailFromTextField.stringValue = UserDefaults.get(by: .emailAddress)
        
        subjectTextField.isEditable = false
        emailToTextField.isEditable = false
        emailCcTextField.isEditable = false
        emailFromTextField.isEditable = false
        
        emailSendButton.isEnabled = false
        progressIndicator.isHidden = false
        progressIndicator.startAnimation(nil)
        
        MailUtil.send(type) { subject, content in
            self.subjectTextField.stringValue = subject
            
            if self.type == .individual {
                self.markdownTextView.string = content
            }
            try? self.downView.update(markdownString: content)
            
            self.progressIndicator.stopAnimation(nil)
            self.progressIndicator.isHidden = true
            
            self.subjectTextField.isEditable = true
            self.emailToTextField.isEditable = true
            self.emailCcTextField.isEditable = true
            self.emailSendButton.isEnabled = true
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
        guard let url = downView.url,
            let content = try? String(contentsOf: url) else {
                NSAlert.show("网页出现了点问题", ["OK, I will try agian."])
                return
        }
        
        MailUtil().send(from, to, cc, subject, content) { errorMessage in
            self.progressIndicator.stopAnimation(nil)
            self.subjectTextField.isEditable = true
            self.emailToTextField.isEditable = true
            self.emailCcTextField.isEditable = true
            self.progressIndicator.isHidden = true
            self.emailSendButton.isEnabled = true
            
            if let errorMessage = errorMessage {
                NSAlert.show("Send failed!", ["OK"], errorMessage)
            } else {
                NSAlert.show("Send successfully!", ["OK"])
            }
        }
    }
}

extension SendPreviewWindowController: NSTextViewDelegate {
    func textDidChange(_ notification: Notification) {
        try? downView.update(markdownString: markdownTextView.string)
    }
}
