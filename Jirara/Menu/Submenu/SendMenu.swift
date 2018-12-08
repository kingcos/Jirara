//
//  SendMenu.swift
//  Jirara
//
//  Created by kingcos on 2018/7/27.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

class SendMenu: NSMenu {
    let summaryController = SendPreviewWindowController()
    
    required init(coder decoder: NSCoder) {
        super.init(coder: decoder)
        
        setup()
    }
    
    override init(title: String) {
        super.init(title: title)
        
        setup()
    }
    
    func setup() {
        let teamItem = NSMenuItem(title: SummaryType.team.rawValue, action: #selector(sendSummary(_:)), keyEquivalent: "")
        let indivitualItem = NSMenuItem(title: SummaryType.individual.rawValue, action: #selector(sendSummary(_:)), keyEquivalent: "")
        
        [teamItem, indivitualItem].forEach { item in
            item.target = self
            addItem(item)
        }
    }
    
    @objc func sendSummary(_ sender: NSMenuItem) {
        guard let type = SummaryType(rawValue: sender.title) else {
            fatalError()
        }
        
        summaryController.type = type
        summaryController.showWindow(nil)
    }
}
