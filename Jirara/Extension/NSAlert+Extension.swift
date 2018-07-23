//
//  NSAlert+Extension.swift
//  Jirara
//
//  Created by kingcos on 2018/6/13.
//  Copyright © 2018 kingcos. All rights reserved.
//

import AppKit

extension NSAlert {
    class func show(_ message: String, _ buttonTitles: [String], _ informativeText: String? = nil) {
        let alert = NSAlert()
        alert.window.backgroundColor = NSColor(hex: "#333333")
        alert.window.titleVisibility = .hidden
        alert.window.titlebarAppearsTransparent = true
        
        if let informativeText = informativeText {
            alert.informativeText = informativeText
        }
        alert.messageText = message
        _ = buttonTitles.map {
            alert.addButton(withTitle: $0)
        }
        
        alert.runModal()
    }
}
