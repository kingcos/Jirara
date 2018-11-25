//
//  MainMenu.swift
//  Jirara
//
//  Created by kingcos on 2018/7/26.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

class MainMenu: NSMenu {
    let aboutController = AboutWindowController()
    let preferenceController = PreferencesWindowController()
}

extension MainMenu {
    func setupMainMenu() {
        // Send
        let firstMenuItem = NSMenuItem.init(title: "Scrums", action: nil, keyEquivalent: "")
        addItem(firstMenuItem)
        setSubmenu(SendMenu.init(), for: firstMenuItem)
        
        // Jira Issues
        let secondMenuItem = NSMenuItem.init(title: "Issues", action: nil, keyEquivalent: "")
        addItem(secondMenuItem)
        setSubmenu(IssuesMenu.init(), for: secondMenuItem)
        
        // ---
        addItem(NSMenuItem.separator())
        
        // Preferences... About Quit Items
        let preferenceItem = NSMenuItem.init(title: "Preferences...", action: #selector(clickOnPreference), keyEquivalent: "")
        let aboutItem = NSMenuItem.init(title: "About", action: #selector(clickOnAbout), keyEquivalent: "")
        let quitItem = NSMenuItem.init(title: "Quit", action: #selector(clickOnQuit), keyEquivalent: "")
        
        [preferenceItem, aboutItem, quitItem].forEach { item in
            item.target = self
            addItem(item)
        }
    }
}

extension MainMenu {
    @objc func clickOnPreference() {
        preferenceController.showWindow(nil)
    }
    
    @objc func clickOnAbout() {
        aboutController.showWindow(nil)
    }
    
    @objc func clickOnQuit() {
        NSApplication.shared.terminate(self)
    }
}
