//
//  LoadingItemView.swift
//  Jirara
//
//  Created by kingcos on 2018/12/7.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

class LoadingItemView: NSView {
    @IBOutlet weak var spinIndicator: NSProgressIndicator!
    
    class func load(_ owner: Any?) -> LoadingItemView? {
        let ib = NSNib(nibNamed: .LoadingItemView, bundle: nil)
        var arr: NSArray?
        if !(ib?.instantiate(withOwner: owner, topLevelObjects: &arr) ?? false){
            return nil
        }
        
        for obj in arr ?? [] {
            if let view = obj as? LoadingItemView {
                view.spinIndicator.startAnimation(owner)
                return view
            }
        }
        
        return nil
    }
}
