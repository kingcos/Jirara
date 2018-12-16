//
//  MainMenu.swift
//  Jirara
//
//  Created by kingcos on 2018/7/26.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

import RxSwift
import RxCocoa

class MainMenu: NSMenu {
    let aboutController = AboutWindowController()
    let preferenceController = PreferencesWindowController()
    
    lazy var viewModel = MainMenuViewModel()
    let bag = DisposeBag()
    
    init() {
        super.init(title: "")
        
        setup()
    }
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
    }
}

extension MainMenu {
    func setup() {
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
        let preferencesItem = NSMenuItem(title: "Preferences...", action: #selector(clickOnPreference), keyEquivalent: "")
        let aboutItem = NSMenuItem(title: "About", action: #selector(clickOnAbout), keyEquivalent: "")
        let quitItem = NSMenuItem(title: "Quit", action: #selector(clickOnQuit), keyEquivalent: "")
        
        [preferencesItem, aboutItem, quitItem].forEach { item in
            item.target = self
            addItem(item)
        }
        
        binding()
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
    func binding() {
        // NSMenu Open Event ==> ViewModel MenuOpen Input
        rx.menuWillOpen.bind(to: viewModel.inputs.menuOpened).disposed(by: bag)
        // NSMenu Close Event ==> ViewModel MenuClose Input
        rx.menuDidClose.bind(to: viewModel.inputs.menuClosed).disposed(by: bag)
        
        // ViewModel [Issue] Output ==> Menu View Update
        viewModel
            .outputs
            .issues
            .subscribe(onNext: { issues in
                if let item = self.item(at: 1),
                   let submenu = item.submenu {
                    submenu.items[2..<submenu.items.count].forEach {
                        submenu.removeItem($0)
                    }
                }

                guard !issues.isEmpty else { return }
                if let menuItem = self.item(at: 1) {
                    if let submenu = menuItem.submenu,
                        submenu.items.count > 2 {
                        submenu.removeItem(at: 2)
                    }
                    issues
                        .filter { $0.assignee == UserDefaults.get(by: .accountUsername) }
                        .forEach {
                            let issueItem = NSMenuItem(title: $0.summary, action: nil, keyEquivalent: "")
                            issueItem.submenu = NSMenu(title: "")
                            
                            let viewDetailsItem = NSMenuItem(title: "View Details...", action: #selector(self.clickOnViewDetails(_:)), keyEquivalent: "")
                            viewDetailsItem.target = self
                            issueItem.submenu?.addItem(viewDetailsItem)
                            issueItem.submenu?.addItem(NSMenuItem.separator())
                            
                            let state = $0.status
                            $0.transitions.forEach {
                                let transitionItem = NSMenuItem(title: $0.name, action: #selector(self.selectedTransitionItem(_:)), keyEquivalent: "")
                                transitionItem.target = self
                                if state == $0.name {
                                    transitionItem.state = .on
                                }
                                issueItem.submenu?.addItem(transitionItem)
                            }
                            menuItem.submenu?.addItem(issueItem)
                    }
                }
            })
            .disposed(by: self.bag)
    }
    
    @objc func clickOnViewDetails(_ item: NSMenuItem) {
//        guard let selectedIssueIndex = selectedIssueIndex,
//            let url = URL(string: JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + "/browse/" + issues[selectedIssueIndex - issueMenuStickItemsCount].key) else {
//                fatalError()
//        }
//
//        NSWorkspace.shared.open(url)
        
        if let parent = item.parent {
            viewModel.inputs.clickOnViewDetails.onNext(parent.title)
        }
    }
    
    @objc func selectedTransitionItem(_ item: NSMenuItem) {
        if let parent = item.parent {
            viewModel.inputs.clickOnTransition.onNext((parent.title, item.title))
        }
    }
}
