//
//  IssuesStatusHeaderView.swift
//  Jirara
//
//  Created by kingcos on 2018/6/14.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

class IssuesStatusHeaderView: NSView {

    @IBOutlet weak var statusTextField: NSTextField!
    
    var status: String? {
        didSet {
            guard let status = status else { return }
            
            statusTextField.stringValue = status
        }
    }
    
    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        // Drawing code here.
    }
    
}
