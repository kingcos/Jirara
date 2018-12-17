//
//  NSTextView+Rx.swift
//  Jirara
//
//  Created by kingcos on 2018/12/16.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation

import RxSwift
import RxCocoa

extension Reactive where Base: NSTextView {
    public var delegate: DelegateProxy<NSTextView, NSTextViewDelegate> {
        return NSTextViewDelegateProxy.proxy(for: base)
    }
    
    public var textDidChange: ControlEvent<Void> {
        let source = delegate.methodInvoked(#selector(NSTextViewDelegate.textDidChange(_:))).map { _ in }
        return ControlEvent(events: source)
    }
}

class NSTextViewDelegateProxy
    : DelegateProxy<NSTextView, NSTextViewDelegate>,
    DelegateProxyType,
    NSTextViewDelegate {
    
    public weak private(set) var textView: NSTextView?
    
    public init(textView: ParentObject) {
        self.textView = textView
        super.init(parentObject: textView, delegateProxy: NSTextViewDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { NSTextViewDelegateProxy(textView: $0) }
    }
    
    static func currentDelegate(for object: NSTextView) -> NSTextViewDelegate? {
        return object.delegate
    }
    
    static func setCurrentDelegate(_ delegate: NSTextViewDelegate?, to object: NSTextView) {
        object.delegate = delegate
    }
}
