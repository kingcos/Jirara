//
//  AppDelegate.swift
//  Jirara
//
//  Created by kingcos on 2018/6/12.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        Timer.shared.scheduled(.jiraRefresher,
                               60,
                               .global(),
                               true) {
                                MainViewModel.fetch(Constants.RapidViewName, false) {
                                    MainViewModel.fetch(Constants.RapidViewName) {
                                        NSUserNotification.send("Finished refreshing!")
                                    }
                                }
        }
        
        statusItem.button?.title = "Jirara"
        
        setupMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

extension AppDelegate {
    func setupMenu() {
        let menu = MainMenu.init()
        menu.setupMainMenu()
        statusItem.menu = menu
    }
}

extension AppDelegate: NSUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: NSUserNotificationCenter,
                                shouldPresent notification: NSUserNotification) -> Bool {
        return true
    }
}
