//
//  AboutWindowController.swift
//  Jirara
//
//  Created by kingcos on 2018/6/29.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

class AboutWindowController: NSWindowController {

    override var windowNibName: NSNib.Name? {
        return .AboutWindowController
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        window?.center()
        window?.makeKeyAndOrderFront(nil)
    }
    
}
