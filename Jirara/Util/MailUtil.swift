//
//  MailUtil.swift
//  Jirara
//
//  Created by kingcos on 2018/6/14.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

struct MailUtil {
    static func send(_ contents: [Any],
                     to recipients: [String],
                     with subject: String = "Weekly Summary") {
        let service = NSSharingService(named: .composeEmail)
        service?.recipients = recipients
        service?.subject = subject
        
        service?.perform(withItems: contents)
    }
}
