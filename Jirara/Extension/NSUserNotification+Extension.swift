//
//  NSUserNotification+Extension.swift
//  Jirara
//
//  Created by kingcos on 2018/7/13.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation

extension NSUserNotification {
    class func send(_ title: String,
                    _ subtitle: String? = nil,
                    _ informativeText: String = "by Jirara") {
        let notification = NSUserNotification.init()
        notification.title = title
        notification.subtitle = subtitle
        notification.informativeText = informativeText
        
        NSUserNotificationCenter.default.deliver(notification)
    }
}
