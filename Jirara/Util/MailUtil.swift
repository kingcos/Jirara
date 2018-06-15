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
    
    static func send(_ content: String,
                     to recipients: [String],
                     with subject: String = "Weekly Summary") {
        guard let service = NSSharingService(named: .composeEmail) else {
            fatalError()
        }
        
        var items = [Any]()
        
        let options = [NSAttributedString.DocumentReadingOptionKey.documentType : NSAttributedString.DocumentType.html]
        let data = content.data(using: .utf8) ?? Data()
        let html = NSAttributedString(html: data, options: options, documentAttributes: nil)
        
        items.append(html)
        
        service.recipients = recipients
        service.subject = subject
        
        service.perform(withItems: items)
    }
    
//    static func send() {
//        let urlString = ""
//        NSURL(string: <#T##String#>)
//        NSWorkspace.shared.
//    }
}
