//
//  EngineersListViewController.swift
//  Jirara
//
//  Created by kingcos on 2018/6/13.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa
import Kingfisher

class EngineersListViewController: NSViewController {

    @IBOutlet weak var listOutlineView: NSOutlineView!
    
    var viewModel = MainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置 dataSource & delegate
        listOutlineView.dataSource = self
        listOutlineView.delegate = self
        
        listOutlineView.expandItem(listOutlineView.item(atRow: 0))
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updatedRemoteData),
                                               name: .UpdatedRemoteData,
                                               object: nil)
    }
    
    func isHeader(_ item: Any) -> Bool {
        if let header = item as? String {
            return header == "ENGINEERS"
        } else {
            return false
        }
    }
}

// MARK: DataSource
extension EngineersListViewController: NSOutlineViewDataSource {
    func outlineView(_ outlineView: NSOutlineView,
                     numberOfChildrenOfItem item: Any?) -> Int {
        guard item != nil else { return 1 }
        
        return viewModel.engineers.count
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     isItemExpandable item: Any) -> Bool {
        return isHeader(item)
    }
    
    func outlineView(_ outlineView: NSOutlineView,
                     child index: Int,
                     ofItem item: Any?) -> Any {
        guard item != nil else { return "ENGINEERS" }
        
        return viewModel.engineers[index]
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
            guard let engineer = item as? EngineerRealm else {
                fatalError()
            }
            
            let modifier = AnyModifier { urlRequest in
                var request = urlRequest
                request.setValue(UserDefaults.get(by: .accountAuth), forHTTPHeaderField: "Authorization")
                return request
            }
            
            view?.nameTextField.stringValue = engineer.displayName
            view?.avatarImageView.kf.setImage(with: URL(string: engineer.avatarURL), options: [.requestModifier(modifier)])
            
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
//        let engineer = viewModel.engneers[listOutlineView.selectedRow - 1]
        let selectedIndex = listOutlineView.selectedRow - 1
        
        NotificationCenter.default.post(name: .SelectedEngineer,
                                        object: self,
                                        userInfo: [Constants.NotificationInfoKey.engineer : selectedIndex])
    }
}

extension EngineersListViewController {
    @objc func updatedRemoteData() {
        listOutlineView.reloadData()
    }
}
