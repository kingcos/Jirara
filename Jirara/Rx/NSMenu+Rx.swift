//
//  NSMenu+Rx.swift
//  Jirara
//
//  Created by kingcos on 2018/12/7.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

extension Reactive where Base: NSMenu {
    public var delegate: DelegateProxy<NSMenu, NSMenuDelegate> {
        return NSMenuDelegateProxy.proxy(for: base)
    }
    
    public var menuWillOpen: ControlEvent<Void> {
        let source = delegate.methodInvoked(#selector(NSMenuDelegate.menuWillOpen(_:))).map { _ in }
        return ControlEvent(events: source)
    }
    
    public var menuDidClose: ControlEvent<Void> {
        let source = delegate.methodInvoked(#selector(NSMenuDelegate.menuDidClose(_:))).map { _ in }
        return ControlEvent(events: source)
    }
}

class NSMenuDelegateProxy
    : DelegateProxy<NSMenu, NSMenuDelegate>,
    DelegateProxyType,
    NSMenuDelegate {
    
    public weak private(set) var menu: NSMenu?
    
    public init(menu: ParentObject) {
        self.menu = menu
        super.init(parentObject: menu, delegateProxy: NSMenuDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { NSMenuDelegateProxy(menu: $0) }
    }
    
    static func currentDelegate(for object: NSMenu) -> NSMenuDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: NSMenuDelegate?, to object: NSMenu) {
        object.delegate = delegate
    }
}
