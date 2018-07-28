//
//  SendMenu.swift
//  Jirara
//
//  Created by kingcos on 2018/7/27.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

class SendMenu: NSMenu {
    override init(title: String) {
        super.init(title: title)
        
        setup()
    }
    
    required init(coder decoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SendMenu {
    func setup() {
        
    }
}
