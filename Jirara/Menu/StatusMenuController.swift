//
//  StatusMenuController.swift
//  Jirara
//
//  Created by kingcos on 2018/6/25.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

class StatusMenuController: NSObject {
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    var preferencesWindowController: PreferencesWindowController!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    override func awakeFromNib() {
        setupStatusItem()
        
        preferencesWindowController = PreferencesWindowController()
    }
}

// MARK: IBAction
extension StatusMenuController {
    @IBAction func clickOnPreferences(_ sender: NSMenuItem) {
        preferencesWindowController.showWindow(nil)
    }
    
    @IBAction func clickOnQuit(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
}

extension StatusMenuController {
    func setupStatusItem() {
        statusItem.menu = statusMenu
        statusItem.button?.title = "Jirara"
    }
    
}
