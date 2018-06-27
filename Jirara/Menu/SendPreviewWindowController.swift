//
//  SendPreviewWindowController.swift
//  Jirara
//
//  Created by kingcos on 2018/6/27.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

class SendPreviewWindowController: NSWindowController {

    override var windowNibName: NSNib.Name? {
        return .SendPreviewWindowController
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.center()
        window?.makeKeyAndOrderFront(nil)
    }
    
}
