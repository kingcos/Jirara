//
//  IssuesMenu.swift
//  Jirara
//
//  Created by kingcos on 2018/7/27.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

class IssuesMenu: NSMenu {
    override init(title: String) {
        super.init(title: title)

        setup()
    }

    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)

        setup()
    }
    
    func setup() {
        // New Issue
        let newIssuesItem = NSMenuItem(title: "New Issue...", action: #selector(clickOnNewIssue), keyEquivalent: "")
        newIssuesItem.target = self
        addItem(newIssuesItem)
        
        // ---
        addItem(NSMenuItem.separator())
        
        // Loading
        let loadingItem = NSMenuItem()
        loadingItem.view = LoadingItemView.load(self)
        addItem(loadingItem)
    }
    
    @objc func clickOnNewIssue() {
        let createIssueURL = UserDefaults.get(by: .accountJiraDomain) + "/secure/CreateIssue!default.jspa"
        guard let url = URL(string: createIssueURL) else {
            fatalError()
        }

        NSWorkspace.shared.open(url)
    }
}
