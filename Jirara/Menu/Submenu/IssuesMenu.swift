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
    var issues: [IssueRealm] = []
    
    let issueMenuStickItemsCount = 2
    
    override init(title: String) {
        super.init(title: title)
        
        delegate = self
        setup()
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension IssuesMenu {
    func setup() {
        let newIssuesItem = NSMenuItem.init(title: "New Issue...",
                                            action: #selector(clickOnNewIssue),
                                            keyEquivalent: "")
        
        newIssuesItem.target = self
        addItem(newIssuesItem)
        
        addItem(NSMenuItem.separator())
    }
    
    @objc func clickOnNewIssue() {
        let createIssueURL = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + "/secure/CreateIssue!default.jspa"
        guard let url = URL.init(string: createIssueURL) else {
            fatalError()
        }
        
        NSWorkspace.shared.open(url)
    }
}

extension IssuesMenu: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        MainViewModel.fetchMyIssuesInActiveSprintReport { issues in
            issues.forEach { issue in
                let submenu = NSMenu.init()
                let menuItem = NSMenuItem(title: issue.summary,
                                          action: nil,
                                          keyEquivalent: "")
                
                let viewDetailsItem = NSMenuItem.init(title: "View Details...",
                                                      action: #selector(self.clickOnViewDetails(_:)),
                                                      keyEquivalent: "")
                viewDetailsItem.target = self
                submenu.addItem(viewDetailsItem)
                submenu.addItem(NSMenuItem.separator())
                
                issue.transitions.forEach {
                    let item = NSMenuItem.init(title: $0.name,
                                               action: #selector(self.clickOnTransition(_:)),
                                               keyEquivalent: "")
                    if issue.status == $0.name {
                        item.state = .on
                    }
                    item.target = self
                    
                    submenu.addItem(item)
                }
                
                DispatchQueue.main.async {
                    menu.insertItem(menuItem, at: self.issueMenuStickItemsCount)
                    menu.setSubmenu(submenu, for: menuItem)
                }
            }
        }
    }
    
    func menuDidClose(_ menu: NSMenu) {
        for item in menu.items {
            if menu.index(of: item) >= issueMenuStickItemsCount {
                menu.removeItem(item)
            }
        }
    }
    
    func menu(_ menu: NSMenu, willHighlight item: NSMenuItem?) {
        guard let item = item else { return }
        selectedIssueIndex = menu.index(of: item)
    }
}

extension IssuesMenu {
    @objc func clickOnViewDetails(_ sender: NSMenuItem) {
        guard let selectedIssueIndex = selectedIssueIndex,
            let url = URL.init(string: JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + "/browse/" + issues[selectedIssueIndex - issueMenuStickItemsCount].key) else {
                fatalError()
        }
        
        NSWorkspace.shared.open(url)
    }
    
    @objc func clickOnIssueItem(_ sender: NSMenuItem) {
        selectedIssueIndex = index(of: sender)
    }
    
    @objc func clickOnTransition(_ sender: NSMenuItem) {
        guard let selectedIssueIndex = selectedIssueIndex else { fatalError() }
        let issue = issues[selectedIssueIndex - issueMenuStickItemsCount]
        
        guard let transitionID = IssueTransitionRealmDAO.findByName(sender.title)?.id else { return }
        
        IssueViewModel.updateTransition(issue.id, transitionID) {
            IssueRealmDAO.update("status", issue) {
                $0.status = sender.title
            }
            NSUserNotification.send(issue.title, "进度已更新至 " + sender.title)
        }
    }
}
