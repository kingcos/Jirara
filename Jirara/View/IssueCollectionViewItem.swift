//
//  IssueCollectionViewItem.swift
//  Jirara
//
//  Created by kingcos on 2018/6/14.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

class IssueCollectionViewItem: NSCollectionViewItem {

    @IBOutlet weak var summaryTextField: NSTextField!
    
    var issue: IssueRealm? {
        didSet {
            guard let issue = issue else { return }
            summaryTextField.stringValue = issue.summary
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        view.wantsLayer = true
    }
    
}
