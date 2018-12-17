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
        setupUIControlsTo(false)
        
        markdownTextView.string = ""
        try? markdownView.update(markdownString: "")
        
    }
    
    func setupUIControlsTo(_ enabled: Bool = true) {
        subjectTextField.isEditable = enabled
        emailToTextField.isEditable = enabled
        emailCcTextField.isEditable = enabled
        emailFromTextField.isEditable = enabled
        markdownTextView.isEditable = enabled
        
        emailSendButton.isEnabled = enabled
        progressIndicator.isHidden = enabled
    }
    
    func setupHeaderContent() {
        emailToTextField.stringValue = UserDefaults.get(by: .emailTo)
        emailCcTextField.stringValue = UserDefaults.get(by: .emailCc)
        emailFromTextField.stringValue = UserDefaults.get(by: .emailAddress)
        subjectTextField.stringValue = UserDefaults.get(by: .mailSubject)
        
        progressIndicator.startAnimation(nil)
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
            self.setupUIControlsTo(false)

            let from = self.emailFromTextField.stringValue
            let to = self.emailToTextField.stringValue.split(separator: " ").map { String($0) }
            let cc = self.emailCcTextField.stringValue.split(separator: " ").map { String($0) }
            let subject = self.subjectTextField.stringValue

            let down = Down(markdownString: self.markdownTextView.string)
            
            do {
                let markdown = try down.toHTML()
                
                MailUtil().send(from, to, cc, subject, markdown) { errorMessage in
                    self.setupUIControlsTo(true)
                    
                    if let errorMessage = errorMessage {
                        NSAlert.show("Send failed!", ["OK"], errorMessage)
                    } else {
                        NSAlert.show("Send successfully!", ["OK"])
                    }
                }
            } catch {
                NSAlert.show("Parse ERROR", ["OK"])
                return
            }
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
        
        viewModel
            .outputs
            .mailContent
            .subscribe(onNext: {
                self.markdownTextView.string = $0
                try? self.markdownView.update(markdownString: $0)
                
                self.setupUIControlsTo()
                
                
            })
            .disposed(by: bag)
    }
}
