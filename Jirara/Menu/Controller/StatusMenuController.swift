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

// MARK: IBAction
extension StatusMenuController {
    @IBAction func clickOnSendTeamSummary(_ sender: NSMenuItem) {
        sendPreviewWindowController.type = .team
        sendPreviewWindowController.showWindow(nil)
    }
    
    @IBAction func clickOnSendIndividualSummary(_ sender: NSMenuItem) {
        sendPreviewWindowController.type = .individual
        sendPreviewWindowController.showWindow(nil)
    }
    
    @IBAction func clickOnPreferences(_ sender: NSMenuItem) {
        preferencesWindowController.showWindow(nil)
    }
    
    @IBAction func clickOnAbout(_ sender: NSMenuItem) {
        aboutWindowController.showWindow(nil)
    }
    
    @IBAction func clickOnQuit(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    @IBAction func clickOnNewIssue(_ sender: NSMenuItem) {
        let createIssueURL = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + "/secure/CreateIssue!default.jspa"
        guard let url = URL.init(string: createIssueURL) else {
            fatalError()
        }
        
        NSWorkspace.shared.open(url)
    }
}

extension StatusMenuController {
    func setupStatusItem() {
        statusItem.menu = statusMenu
        statusItem.button?.title = "Jirara"
    }
    
    func setupMenuItems() {
        issuesMenu.delegate = self
//
//        // Setup My Issues submenu view
//        guard let issuesSubmenu = statusMenu.item(at: 1)?.submenu else {
//            return
//        }
        
    }
}

extension StatusMenuController: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
//        let menuItem = NSMenuItem.init(title: "Test", action: nil, keyEquivalent: "")
//        menu.insertItem(menuItem, at: 2)
//        let submenu = NSMenu.init()
//        menu.setSubmenu(submenu, for: menuItem)
        

        
//        MainViewModel.fetch { _, engineers in
//            let engineer = engineers.filter { $0.name == UserDefaults.get(by: .accountUsername) }
//            for issue in engineer[0].issues {
//                DispatchQueue.main.async {
//                    let menuItem = NSMenuItem.init(title: issue.summary,
//                                                   action: nil,
//                                                   keyEquivalent: "")
//                    menu.insertItem(menuItem, at: 2)
//                    let submenu = NSMenu.init()
//
//                    let viewDetailsItem = NSMenuItem.init(title: "View Details...",
//                                                      action: #selector(self.clickOnViewDetails(_:)),
//                                                      keyEquivalent: "")
//                    viewDetailsItem.target = self
//                    submenu.addItem(viewDetailsItem)
//                    menu.setSubmenu(submenu, for: menuItem)
//                }
//            }
//        }
        
        guard let sprintReport = SprintReportRealmDAO.findLatest() else { return }
        issues = sprintReport.issues.filter { $0.assignee == UserDefaults.get(by: .accountUsername) }
        
        for issue in issues.reversed() {
            let submenu = NSMenu.init()
            let menuItem = NSMenuItem.init(title: issue.title,
                                           action: nil,
                                           keyEquivalent: "")
            let viewDetailsItem = NSMenuItem.init(title: "View Details...",
                                                  action: #selector(self.clickOnViewDetails(_:)),
                                                  keyEquivalent: "")
            viewDetailsItem.target = self
            submenu.addItem(viewDetailsItem)
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
    
    @objc func clickOnViewDetails(_ sender: NSMenuItem) {
        guard let selectedIssueIndex = selectedIssueIndex else { fatalError() }
        print(issues[selectedIssueIndex - issueMenuStickItemsCount].title)
    }
    
    @objc func clickOnIssueItem(_ sender: NSMenuItem) {
        selectedIssueIndex = issuesMenu.index(of: sender)
    }
}
