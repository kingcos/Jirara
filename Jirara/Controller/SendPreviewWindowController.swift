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
import RxSwift
import RxCocoa

fileprivate extension NSTouchBar.CustomizationIdentifier {
    static let touchBar = NSTouchBar.CustomizationIdentifier("com.maimieng.jirara.touchbar")
}

fileprivate extension NSTouchBarItem.Identifier {
    static let send = NSTouchBarItem.Identifier("com.maimieng.jirara.touchbar.send")
}

class SendPreviewWindowController: NSWindowController {
    
    @IBOutlet weak var subjectTextField: NSTextField!
    @IBOutlet weak var emailToTextField: NSTextField!
    @IBOutlet weak var emailCcTextField: NSTextField!
    @IBOutlet weak var emailFromTextField: NSTextField!
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var emailSendButton: NSButton!
    
    @IBOutlet weak var markdownContainerView: NSView!
    @IBOutlet weak var markdownTextView: NSTextView!
    
    var markdownView: DownView!
    
    lazy var viewModel = PreviewViewModel()
    let bag = DisposeBag()
    
    var content = ""
    
    override var windowNibName: NSNib.Name? {
        return .SendPreviewWindowController
    }
    
    override func windowDidLoad() {
        setupMardownViews()
        
        binding()
    }
    
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        
        viewModel.inputs.previewWindowDidShow.onNext(())
        
        // Show window at most front all the time
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
        
        setupHeaderContent()
        markdownTextView.string = ""
        try? markdownView.update(markdownString: "")
    }
    
    func setupHeaderContent() {
        emailToTextField.stringValue = UserDefaults.get(by: .emailTo)
        emailCcTextField.stringValue = UserDefaults.get(by: .emailCc)
        emailFromTextField.stringValue = UserDefaults.get(by: .emailAddress)
        subjectTextField.stringValue = UserDefaults.get(by: .mailSubject)
        
//        subjectTextField.isEditable = false
//        emailToTextField.isEditable = false
//        emailCcTextField.isEditable = false
//        emailFromTextField.isEditable = false
//
//        emailSendButton.isEnabled = false
//        progressIndicator.isHidden = false
//        progressIndicator.startAnimation(nil)
        
//        MailUtil.send { subject, content in
//            self.content = content
//
//            self.subjectTextField.stringValue = subject
//            self.markdownTextView.string = content
//
//            try? self.downView.update(markdownString: content)
//
//            self.progressIndicator.stopAnimation(nil)
//            self.progressIndicator.isHidden = true
//
//            self.subjectTextField.isEditable = true
//            self.emailToTextField.isEditable = true
//            self.emailCcTextField.isEditable = true
//            self.emailSendButton.isEnabled = true
//        }
    }
    
    func setupMardownViews() {
        markdownTextView.textContainerInset = NSSize(width: 10, height: 5)
        
        try? markdownView = DownView(frame: markdownContainerView.bounds, markdownString: "")
        markdownContainerView.addSubview(markdownView)
        
        markdownView.snp.makeConstraints { maker in
            maker.edges.equalToSuperview()
        }
    }
    
    func binding() {
        emailSendButton.rx.tap.subscribe(onNext: {
//            subjectTextField.isEditable = false
//            emailToTextField.isEditable = false
//            emailCcTextField.isEditable = false
//
//            progressIndicator.isHidden = false
//            progressIndicator.startAnimation(nil)
//
//            emailSendButton.isEnabled = false
//
//            let from = emailFromTextField.stringValue
//            let to = emailToTextField.stringValue.split(separator: " ").map { String($0) }
//            let cc = emailCcTextField.stringValue.split(separator: " ").map { String($0) }
//            let subject = subjectTextField.stringValue
//
//            let down = Down(markdownString: markdownTextView.string)
//            if let markdown = try? down.toHTML() {
//                content = markdown
//            } else {
//                NSAlert.show("Parse ERROR", ["OK"])
//                return
//            }
//            MailUtil().send(from, to, cc, subject, content) { errorMessage in
//                self.progressIndicator.stopAnimation(nil)
//                self.subjectTextField.isEditable = true
//                self.emailToTextField.isEditable = true
//                self.emailCcTextField.isEditable = true
//                self.progressIndicator.isHidden = true
//                self.emailSendButton.isEnabled = true
//
//                if let errorMessage = errorMessage {
//                    NSAlert.show("Send failed!", ["OK"], errorMessage)
//                } else {
//                    NSAlert.show("Send successfully!", ["OK"])
//                }
//            }
        })
        .disposed(by: bag)
        
        markdownTextView
            .rx
            .textDidChange
            .bind(to: viewModel.inputs.markdownTextDidChange)
            .disposed(by: bag)
        
        viewModel.outputs.updateMardownView.subscribe(onNext: {
            try? self.markdownView.update(markdownString: self.markdownTextView.string)
        })
        .disposed(by: bag)
        
        
    }
}
