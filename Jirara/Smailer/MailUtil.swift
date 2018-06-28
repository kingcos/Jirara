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
        session.port = UInt32(UserDefaults.get(by: .emailPort)) ?? 587
    }

    func send(_ from: String,
              _ to: [String],
              _ cc: [String],
              _ subject: String,
              _ content: String,
//              _ attachment: Data?,
              completion: @escaping () -> Void) {
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
                print((error as NSError).description)
            }

            completion()
        }
    }
    
    static func send(_ completion: @escaping (String, String) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        
        // 上周数据
        MainViewModel.fetchLast { lastSprintReport, engineersRealm in
            let subject = "iOS Engineers 周报 \(lastSprintReport.startDate) ~ \(lastSprintReport.endDate)"
            let today = formatter.string(from: Date())
            var content =
"""
<h2>Mobike - iOS Engineers 本周工作报告</h2>
<h3>周期：\(lastSprintReport.startDate) ~ \(lastSprintReport.endDate)   统计日期：\(today)</h3>
"""
            let engineers = engineersRealm.reduce("") { result, engineer -> String in
                result + engineer.description
            }
            content.append(engineers)
            
            // 最新数据
            MainViewModel.fetch { nextSprintReport, engineersRealm in
                content.append(
"""
<h2>下周工作预告</h2>
<h3>周期：\(nextSprintReport.startDate) ~ \(nextSprintReport.endDate)</h3>
"""
                )
                
                let engineers = engineersRealm.reduce("") { result, engineer -> String in
                    result + engineer.description
                }
                
                content.append(engineers)
                
                content.append("<br><br><b>注：优先级顺序：高 -> 低 ❤️💛💚；状态：完成 ✅，开始 🏁，进行中为相应文字表述</b>")
                content.append("<br><hr><center><b>Powered by <a href=\"https://github.com/kingcos/Jirara\">Jirara</a> with ❤️</b></center>")
                
                completion(subject, content)
            }
        }
    }
    
    static func send() {
        
    }
}
