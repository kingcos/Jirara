//
//  JiraIssuesMenu.swift
//  Jirara
//
//  Created by kingcos on 2018/7/27.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

class JiraIssuesMenu: NSMenu {
    
    var selectedIssueIndex: Int?
    var issues: [IssueRealm] = []
    
    let issueMenuStickItemsCount = 3
    
    override init(title: String) {
        super.init(title: title)
        
        delegate = self
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

extension JiraIssuesMenu: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        guard let sprintReport = SprintReportRealmDAO.findLatest() else { return }
        issues = sprintReport.issues.filter { $0.assignee == UserDefaults.get(by: .accountUsername) }
        
        issues.forEach { issue in
            issues.append(contentsOf: issue.subtasks.filter { $0.assignee == UserDefaults.get(by: .accountUsername) })
        }
        
        for issue in issues.reversed() {
            let submenu = NSMenu.init()
            let menuItem = NSMenuItem.init(title: issue.parentSummary == "" ? issue.title : issue.parentSummary + " - " + issue.title,
                                           action: nil,
                                           keyEquivalent: "")
            if issue.status == "完成" {
                menuItem.state = .on
            }
            
            let viewDetailsItem = NSMenuItem.init(title: "View Details...",
                                                  action: #selector(self.clickOnViewDetails(_:)),
                                                  keyEquivalent: "")
            viewDetailsItem.target = self
            submenu.addItem(viewDetailsItem)
            submenu.addItem(NSMenuItem.separator())
            
            for progress in Constants.JiraIssueProgresses {
                let item = NSMenuItem.init(title: progress,
                                           action: #selector(self.clickOnProgress(_:)),
                                           keyEquivalent: "")
                item.target = self
                let currentProgress = issue.comments.filter { $0.content.hasPrefix(Constants.JiraIssueProgressPrefix) }.first?.content ?? Constants.JiraIssueProgressTodo
                if currentProgress == Constants.JiraIssueProgressPrefix + progress {
                    item.state = .on
                }
                
                submenu.addItem(item)
            }
            
            menu.insertItem(menuItem, at: issueMenuStickItemsCount)
            menu.setSubmenu(submenu, for: menuItem)
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

extension JiraIssuesMenu {
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
    
    @objc func clickOnProgress(_ sender: NSMenuItem) {
        guard let selectedIssueIndex = selectedIssueIndex else { fatalError() }
        let issue = issues[selectedIssueIndex - issueMenuStickItemsCount]
        IssueViewModel.fetchIssueComments(issue.id) { issueComments in
            IssueViewModel.updateProgress(issue.id, issueComments, sender.title) { newIssue in
                let subtitleSuffix: String
                switch sender.title {
                case Constants.JiraIssueProgressTodo:
                    subtitleSuffix = "，不要忘记开始哟～"
                case Constants.JiraIssueProgressDone:
                    subtitleSuffix = "，太棒啦！"
                default:
                    subtitleSuffix = "，要加油哟～"
                }
                
                NSUserNotification.send(newIssue.title, "进度已更新至 " + sender.title + subtitleSuffix)
            }
        }
    }
}
