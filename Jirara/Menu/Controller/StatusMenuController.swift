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
    @IBOutlet weak var issuesMenu: NSMenu!
    
    var preferencesWindowController: PreferencesWindowController!
    var sendPreviewWindowController: SendPreviewWindowController!
    var aboutWindowController: AboutWindowController!
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    override func awakeFromNib() {
        setupStatusItem()
        setupMenuItems()
        
        preferencesWindowController = PreferencesWindowController()
        sendPreviewWindowController = SendPreviewWindowController()
        aboutWindowController = AboutWindowController()
    }
    
}

// MARK: IBAction
extension StatusMenuController {
    @IBAction func clickOnSendTeamSummary(_ sender: NSMenuItem) {
        sendPreviewWindowController.type = .team
        sendPreviewWindowController.showWindow(nil)
    }
    
    @IBAction func clickOnSendIndividualSummary(_ sender: NSMenuItem) {
        sendPreviewWindowController.type = .individual
        sendPreviewWindowController.showWindow(nil)
    }
    
    @IBAction func clickOnPreferences(_ sender: NSMenuItem) {
        preferencesWindowController.showWindow(nil)
    }
    
    @IBAction func clickOnAbout(_ sender: NSMenuItem) {
        aboutWindowController.showWindow(nil)
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
    
    func setupMenuItems() {
        // Setup My Issues submenu view
        guard let issuesSubmenu = statusMenu.item(at: 1)?.submenu else {
            return
        }
        
    }
}
