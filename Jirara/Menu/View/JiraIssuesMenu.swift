//
//  JiraIssuesMenu.swift
//  Jirara
//
//  Created by kingcos on 2018/7/27.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

class JiraIssuesMenu: NSMenu {
    override init(title: String) {
        super.init(title: title)
        
        setup()
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension JiraIssuesMenu {
    func setup() {
        let newIssuesItem = NSMenuItem.init(title: "New Issue...",
                                            action: #selector(clickOnNewIssue),
                                            keyEquivalent: "")
        let refreshItem = NSMenuItem.init(title: "Refresh",
                                          action: #selector(clickOnRefresh),
                                          keyEquivalent: "")
        
        [newIssuesItem, refreshItem].forEach { item in
            item.target = self
            addItem(item)
        }
        
        addItem(NSMenuItem.separator())
    }
    
    @objc func clickOnNewIssue() {
        let createIssueURL = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + "/secure/CreateIssue!default.jspa"
        guard let url = URL.init(string: createIssueURL) else {
            fatalError()
        }
        
        NSWorkspace.shared.open(url)
    }
    
    @objc func clickOnRefresh() {
        MainViewModel.fetch(Constants.RapidViewName, false) {
            MainViewModel.fetch(Constants.RapidViewName) {
                NSUserNotification.send("Finished refreshing!")
            }
        }
    }
}
