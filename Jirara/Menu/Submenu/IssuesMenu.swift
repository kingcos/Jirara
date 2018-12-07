//
//  IssuesMenu.swift
//  Jirara
//
//  Created by kingcos on 2018/7/27.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

class IssuesMenu: NSMenu {
    var selectedIssueIndex: Int?
    var issues: [Issue] = []
    
    let issueMenuStickItemsCount = 2
    
    override init(title: String) {
        super.init(title: title)
        
        delegate = self
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        delegate = self
    }
}

extension IssuesMenu {
    func setup() {
        let newIssuesItem = NSMenuItem(title: "New Issue...",
                                            action: #selector(clickOnNewIssue),
                                            keyEquivalent: "")
        
        newIssuesItem.target = self
        addItem(newIssuesItem)
        
        addItem(NSMenuItem.separator())
    }
    
    @objc func clickOnNewIssue() {
        let createIssueURL = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + "/secure/CreateIssue!default.jspa"
        guard let url = URL(string: createIssueURL) else {
            fatalError()
        }
        
        NSWorkspace.shared.open(url)
    }
}

extension IssuesMenu: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        setup()
        
        MainViewModel.fetchMyIssuesInActiveSprintReport { issues in
            self.issues = issues.sorted { $0.id > $1.id }
            
            self.issues.reversed().forEach { issue in
                let submenu = NSMenu()
                let menuItem = NSMenuItem(title: issue.summary,
                                          action: nil,
                                          keyEquivalent: "")
                
                let viewDetailsItem = NSMenuItem(title: "View Details...",
                                                      action: #selector(self.clickOnViewDetails(_:)),
                                                      keyEquivalent: "")
                viewDetailsItem.target = self
                submenu.addItem(viewDetailsItem)
                submenu.addItem(NSMenuItem.separator())
                
                issue.transitions.forEach {
                    let item = NSMenuItem(title: $0.name,
                                               action: #selector(self.clickOnTransition(_:)),
                                               keyEquivalent: "")
                    if issue.status == $0.name {
                        item.state = .on
                    }
                    item.target = self
                    
                    submenu.addItem(item)
                }
                
                if menu.items.count >= self.issueMenuStickItemsCount {
                    menu.insertItem(menuItem, at: self.issueMenuStickItemsCount)
                    menu.setSubmenu(submenu, for: menuItem)
                }
            }
        }
    }
    
    func menuDidClose(_ menu: NSMenu) {
        menu.removeAllItems()
    }
    
    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        guard let item = item else { return }
        selectedIssueIndex = menu.index(of: item)
    }
}

extension IssuesMenu {
    @objc func clickOnViewDetails(_ sender: NSMenuItem) {
        guard let selectedIssueIndex = selectedIssueIndex,
            let url = URL(string: JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + "/browse/" + issues[selectedIssueIndex - issueMenuStickItemsCount].key) else {
                fatalError()
        }
        
        NSWorkspace.shared.open(url)
    }
    
    @objc func clickOnTransition(_ sender: NSMenuItem) {
        guard let selectedIssueIndex = selectedIssueIndex else { fatalError() }
        let issue = issues[selectedIssueIndex - issueMenuStickItemsCount]
        
        MainViewModel.fetchTransitions(issue.id) { transitions in
            transitions.forEach { transition in
                if transition.name == sender.title {
                    IssueViewModel.updateTransition(issue.id, transition.id) {
                        // Do sth...
                    }
                }
            }
        }
    }
}
