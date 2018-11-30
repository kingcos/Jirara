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
    
    // Show window at most front all the time
    override func showWindow(_ sender: Any?) {
        super.showWindow(sender)
        
        window?.center()
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @IBAction func showGitHubPage(_ sender: NSButton) {
        NSWorkspace.shared.open(URL(string: "https://github.com/kingcos")!)
    }
}
