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
    
        // 隐藏全屏按钮
        let zoomButton = window?.standardWindowButton(.zoomButton)
        zoomButton?.isHidden = true
        
        // 隐藏最小化按钮
        let miniaturizeButton = window?.standardWindowButton(.miniaturizeButton)
        miniaturizeButton?.isHidden = true
        
        // 隐藏 TitleBar
        window?.titleVisibility = .hidden
        window?.titlebarAppearsTransparent = true
        
        // 设置背景色
        window?.backgroundColor = NSColor(hex: "#333333")
    }

}
