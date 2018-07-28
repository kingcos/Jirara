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
    
    var selectedIssueIndex: Int?
    var issues: [IssueRealm] = []
    
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    let issueMenuStickItemsCount = 3
    
    override func awakeFromNib() {
        setupStatusItem()
        setupMenuItems()
        
        preferencesWindowController = PreferencesWindowController()
        sendPreviewWindowController = SendPreviewWindowController()
        aboutWindowController = AboutWindowController()
    }
}

extension StatusMenuController {
    func setupStatusItem() {
        statusItem.menu = statusMenu
        statusItem.button?.title = "Jirara"
    }
    
    func setupMenuItems() {
        issuesMenu.delegate = self
    }
    
    @objc func clickOnAbout() {
        AboutWindowController().showWindow(nil)
    }
}

extension StatusMenuController: NSMenuDelegate {
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
        selectedIssueIndex = issuesMenu.index(of: item)
    }
}

extension StatusMenuController {
    @objc func clickOnViewDetails(_ sender: NSMenuItem) {
        guard let selectedIssueIndex = selectedIssueIndex,
            let url = URL.init(string: JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + "/browse/" + issues[selectedIssueIndex - issueMenuStickItemsCount].key) else {
                fatalError()
        }
        
        NSWorkspace.shared.open(url)
    }
    
    @objc func clickOnIssueItem(_ sender: NSMenuItem) {
        selectedIssueIndex = issuesMenu.index(of: sender)
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
