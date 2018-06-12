//
//  LoginWindowController.swift
//  Jirara
//
//  Created by kingcos on 2018/6/12.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

class LoginWindowController: NSWindowController {

    override func windowDidLoad() {
        super.windowDidLoad()
        
        // 去除全屏按钮
        let button = window?.standardWindowButton(.zoomButton)
        button?.isHidden = true

        // 隐藏 TitleBar
        window?.titleVisibility = .hidden
        window?.titlebarAppearsTransparent = true
    }
    
}
