//
//  EngineersListViewController.swift
//  Jirara
//
//  Created by kingcos on 2018/6/13.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

class EngineersListViewController: NSViewController {

    @IBOutlet weak var listOutlineView: NSOutlineView!
    
    var engineers = [Engineer]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置 dataSource & delegate
        listOutlineView.dataSource = self
        listOutlineView.delegate = self
    }
    
}

// MARK: DataSource
extension EngineersListViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView,
                     numberOfChildrenOfItem item: Any?) -> Int {
        return 2
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     isItemExpandable item: Any) -> Bool {
        return false
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     child index: Int,
                     ofItem item: Any?) -> Any {
        guard item != nil else { return "ENGNEERS" }
        
        return engineers[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     objectValueFor tableColumn: NSTableColumn?,
                     byItem item: Any?) -> Any? {
        return item
    }
    
}

// MARK: Delegate
extension EngineersListViewController: NSOutlineViewDelegate {

}
