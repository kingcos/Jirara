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
              _ attachment: Data?,
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
    
//    static func send(_ image: NSImage?) {
//        guard let sprintReport = SprintReportRealmDAO.findLatest() else {
//            fatalError()
//        }
//
//        let engineers = EngineerRealmDAO.findAll()
//        let subject = "iOS Eng 周报 \(sprintReport.startDate) ~ \(sprintReport.endDate)"
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = Constants.dateFormat
//        let today = formatter.string(from: Date())
//        var content =
//"""
//<h2> Mobike iOS 本周工作报告</h2>
//<h3>周期：\(sprintReport.startDate) ~ \(sprintReport.endDate) 发送日期：\(today)</h3>
//"""
//
//        let engs = engineers.reduce("") { result, engineer -> String in
//            result + engineer.description
//        }
//
//        content.append(engs)
//
//        content.append("<br><hr><center>Powered by <a href=\"https://github.com/kingcos/Jirara\">Jirara</a> with ❤️</center>")
//
//        MailUtil().send("critic@mobike.com", ["i-maiming@mobike.com"], [], subject, content, image?.tiffRepresentation) {
//
//        }
//    }
    
//    static func send(_ image: NSImage?) {
//        guard let lastSprintReport = SprintReportRealmDAO.findLastLatest(),
//        let nextSprintReport = SprintReportRealmDAO.findLatest() else {
//            fatalError()
//        }
//
//        let engineers = EngineerRealmDAO.findAll()
//        let subject = "iOS Eng 周报 \(lastSprintReport.startDate) ~ \(lastSprintReport.endDate)"
//
//        let formatter = DateFormatter()
//        formatter.dateFormat = Constants.dateFormat
//        let today = formatter.string(from: Date())
//        var content =
//"""
//<h2> Mobike iOS 本周工作报告</h2>
//<h3>周期：\(lastSprintReport.startDate) ~ \(lastSprintReport.endDate) 发送日期：\(today)</h3>
//"""
//
//        let engsLast = engineers.reduce("") { result, engineer -> String in
//            result + engineer.description
//        }
//
//        content.append(engsLast)
//
//        content.append(
//"""
//<hr>
//<h2> Mobike iOS 下周工作报告</h2>
//<h3>周期：\(nextSprintReport.startDate) ~ \(nextSprintReport.endDate)</h3>
//"""
//        )
//        let engsNext = engineers.reduce("") { result, engineer -> String in
//            result + engineer.description
//        }
//
//        content.append(engsNext)
//        content.append("<br><br><b>注：优先级顺序：❤️💛💚，状态：完成 ✅，开始 🏁</b>")
//        content.append("<br><hr><center>Powered by <a href=\"https://github.com/kingcos/Jirara\">Jirara</a> with ❤️</center>")
//
//        MailUtil().send("critic@mobike.com", ["i-maiming@mobike.com"], [], subject, content, image?.tiffRepresentation) {
//
//        }
//    }
    
    
    
    static func send() {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        
        // 取上周数据
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
            
            MainViewModel.fetch { nestSprintReport, engineersRealm in
                content.append(
"""
<h2>下周工作预告</h2>
<h3>周期：\(nestSprintReport.startDate) ~ \(nestSprintReport.endDate)</h3>
"""
                )
                
                let engineers = engineersRealm.reduce("") { result, engineer -> String in
                    result + engineer.description
                }
                
                content.append(engineers)
                
                content.append("<br><br><b>注：优先级顺序：高 -> 低 ❤️💛💚；状态：完成 ✅，开始 🏁，进行中为相应文字表述</b>")
                content.append("<br><hr><center><b>Powered by <a href=\"https://github.com/kingcos/Jirara\">Jirara</a> with ❤️</b></center>")
                
                MailUtil().send("critic@mobike.com", ["product-engineering@mobike.com"], ["clients@mobike.com", "zoujia@mobike.com", "zhangyaochun@mobike.com", "i-maiming@mobike.com"], subject, content, nil) {
                    
                }
            }
        }
        
        
        
        // 取本周数据
        
        // 发送
        
        
        
        
    }
}
