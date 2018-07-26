//
//  MainMenu.swift
//  Jirara
//
//  Created by kingcos on 2018/7/26.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

class MainMenu: NSMenu {
    let summaryController = SendPreviewWindowController()
    let aboutController = AboutWindowController()
    let preferenceController = PreferencesWindowController()
}

extension MainMenu {
    func setupMainMenu() {
        let firstMenuItem = NSMenuItem.init(title: "Send", action: nil, keyEquivalent: "")
        let sendMenu = NSMenu.init()
        sendMenu.addItem(NSMenuItem.init(title: SummaryType.team.rawValue,
                                         action: #selector(sendWeeklySummary(_:)),
                                         keyEquivalent: ""))
        sendMenu.addItem(NSMenuItem.init(title: SummaryType.individual.rawValue,
                                         action: #selector(sendWeeklySummary(_:)),
                                         keyEquivalent: ""))
        addItem(firstMenuItem)
        setSubmenu(sendMenu, for: firstMenuItem)
        
        addItem(NSMenuItem.separator())
        
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
    @objc func sendWeeklySummary(_ sender: NSMenuItem) {
        guard let type = SummaryType(rawValue: sender.title) else {
            fatalError()
        }
        summaryController.type = type
        summaryController.showWindow(nil)
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
