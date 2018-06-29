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
    var sendPreviewWindowController: SendPreviewWindowController!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    override func awakeFromNib() {
        setupStatusItem()
        
        preferencesWindowController = PreferencesWindowController()
        sendPreviewWindowController = SendPreviewWindowController()
    }
    
}

// MARK: IBAction
extension StatusMenuController {
    @IBAction func ClickOnSendWithCategories(_ sender: NSMenuItem) {
        sendPreviewWindowController.type = .categories
        sendPreviewWindowController.showWindow(nil)
    }
    
    @IBAction func clickOnSendWithEngineers(_ sender: NSMenuItem) {
        sendPreviewWindowController.type = .default
        sendPreviewWindowController.showWindow(nil)
    }
    
    @IBAction func clickOnPreferences(_ sender: NSMenuItem) {
        preferencesWindowController.showWindow(nil)
    }
    
    @IBAction func clickOnAbout(_ sender: NSMenuItem) {
//        aboutWindowController.showWindow(nil)
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
