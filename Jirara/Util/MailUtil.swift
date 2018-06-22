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

        session.hostname = "smtp.partner.outlook.cn"
        session.username = "critic@mobike.com"
        session.password = "M@bike20150127"
        session.connectionType = .startTLS
        session.port = 587
    }

    func send(_ from: String,
              _ to: [String],
              _ cc: [String],
              _ subject: String,
              _ content: String,
              completion: @escaping () -> Void) {
        let builder = MCOMessageBuilder.init()
        let fromAddress = MCOAddress.init(displayName: "Critic", mailbox: from)
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
        builder.htmlBody = content

        session.sendOperation(with: builder.data())?.start { error in
            if let error = error {
                print((error as NSError).description)
            }

            completion()
        }
    }
    
    static func send() {
        guard let sprintReport = SprintReportRealmDAO.findLatest() else {
            fatalError()
        }
        
        let engineers = EngineerRealmDAO.findAll()
        
        let subject = "iOS Eng 周报 \(sprintReport.startDate) ~ \(sprintReport.endDate)"
        var content =
"""
<h3>本周工作 \(sprintReport.startDate) ~ \(sprintReport.endDate)</h3>
"""
//        content.append(<#T##other: String##String#>)
        let engs = engineers.reduce("") { result, engineer -> String in
            result + engineer.description
        }
        content.append(engs)
        MailUtil().send("critic@mobike.com", ["i-maiming@mobike.com"], [], subject, content) {
            
        }
    }
}
