//
//  MainWindowController.swift
//  Jirara
//
//  Created by kingcos on 2018/6/12.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

class MainWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
    
        // 隐藏 TitleBar
        window?.titleVisibility = .hidden
        window?.titlebarAppearsTransparent = true
    }

}
