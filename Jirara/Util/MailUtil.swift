//
//  MailUtil.swift
//  Jirara
//
//  Created by kingcos on 2018/6/14.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

struct MailUtil {
    
    var session: MCOSMTPSession

    init() {
        session = MCOSMTPSession.init()

        session.hostname = UserDefaults.get(by: .emailSMTP)
        session.username = UserDefaults.get(by: .emailAddress)
        session.password = UserDefaults.get(by: .emailPassword)
        session.connectionType = .startTLS
        session.port = UInt32(UserDefaults.get(by: .emailPort)) ?? 0
    }

    func send(_ from: String,
              _ to: [String],
              _ cc: [String],
              _ subject: String,
              _ content: String,
//              _ attachment: Data?,
              completion: @escaping (String?) -> Void) {
        let builder = MCOMessageBuilder.init()
        let fromAddress = MCOAddress.init(displayName: from, mailbox: from)
        let toAddresses = to.map { address -> MCOAddress in
            return MCOAddress.init(displayName: "", mailbox: address)
        }
        let ccAddresses = cc.map { address -> MCOAddress in
            return MCOAddress.init(displayName: "", mailbox: address)
        }

        builder.header.from = fromAddress
        builder.header.to = toAddresses
        builder.header.cc = ccAddresses

        builder.header.subject = subject
        
//        let att = MCOAttachment()
//        att.mimeType = "image/jpg"
////        attachment.filename = ""
//        att.data = attachment
//        builder.addRelatedAttachment(att)
        
        builder.htmlBody = content
        
        session.sendOperation(with: builder.data())?.start { error in
            if let error = error {
                completion((error as NSError).description)
            } else {
                completion(nil)
            }
        }
    }
}
