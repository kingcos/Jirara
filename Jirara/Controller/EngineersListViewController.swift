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
    
    var viewModel = MainViewModel()
    var str = ["1", "2", "3"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置 dataSource & delegate
        listOutlineView.dataSource = self
        listOutlineView.delegate = self
        
        listOutlineView.expandItem(listOutlineView.item(atRow: 0))
    }
    
    func isHeader(_ item: Any) -> Bool {
        return (item as! String) == "ENGINEERS"
    }
    
}

// MARK: DataSource
extension EngineersListViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView,
                     numberOfChildrenOfItem item: Any?) -> Int {
        guard item != nil else { return 1 }
        
        return str.count
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     isItemExpandable item: Any) -> Bool {
        return isHeader(item)
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     child index: Int,
                     ofItem item: Any?) -> Any {
        guard item != nil else { return "ENGINEERS" }
        
        return str[index]
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     objectValueFor tableColumn: NSTableColumn?,
                     byItem item: Any?) -> Any? {
        return item
    }
}

// MARK: Delegate
extension EngineersListViewController: NSOutlineViewDelegate {
    func outlineView(_ outlineView: NSOutlineView,
                     viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
        if isHeader(item) {
            return outlineView.makeView(withIdentifier: .init(rawValue: "EngineerHeaderCell"), owner: self)
        } else {
            let view = outlineView.makeView(withIdentifier: .init(rawValue: "EngineerItemCell"), owner: self) as? EngineerCellView
            view?.nameTextField.stringValue = (item as? String) ?? ""
            
            return view
        }
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     shouldSelectItem item: Any) -> Bool {
        return !isHeader(item)
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     shouldShowOutlineCellForItem item: Any) -> Bool {
        return isHeader(item)
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     heightOfRowByItem item: Any) -> CGFloat {
        if isHeader(item) {
            return 20.0
        } else {
            return 50.0
        }
    }
    
    func outlineViewSelectionDidChange(_ notification: Notification) {
        print(str[listOutlineView.selectedRow - 1])
    }
}
