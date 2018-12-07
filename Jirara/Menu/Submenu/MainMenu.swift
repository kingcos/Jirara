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
        delegate = self
        
        // Send
        let firstMenuItem = NSMenuItem(title: "Scrums", action: nil, keyEquivalent: "")
        addItem(firstMenuItem)
        setSubmenu(SendMenu(), for: firstMenuItem)
        
        // Issues
        let secondMenuItem = NSMenuItem(title: "Issues", action: nil, keyEquivalent: "")
        addItem(secondMenuItem)
        setSubmenu(IssuesMenu(), for: secondMenuItem)
        
        // ---
        addItem(NSMenuItem.separator())
        
        // Preferences... About Quit Items
        let preferenceItem = NSMenuItem(title: "Preferences...", action: #selector(clickOnPreference), keyEquivalent: "")
        let aboutItem = NSMenuItem(title: "About", action: #selector(clickOnAbout), keyEquivalent: "")
        let quitItem = NSMenuItem(title: "Quit", action: #selector(clickOnQuit), keyEquivalent: "")
        
        [preferenceItem, aboutItem, quitItem].forEach { item in
            item.target = self
            addItem(item)
        }
    }
    
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

extension MainMenu {
    
}

extension MainMenu: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        
    }
    
    func menuDidClose(_ menu: NSMenu) {
        
    }
}
