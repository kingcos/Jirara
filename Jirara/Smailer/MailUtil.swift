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
    
    
    static func send(_ type: SummaryType, _ completion: @escaping (String, String) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        
        MainViewModel.fetchLast { lastSprintReport, _ in
            let subject = "iOS Engineers 周报 \(lastSprintReport.startDate) ~ \(lastSprintReport.endDate)"
            let today = formatter.string(from: Date())
            var content =
"""
<h2>Mobike - iOS Engineers 本周工作报告</h2>
<h3>周期：\(lastSprintReport.startDate) ~ \(lastSprintReport.endDate)   统计日期：\(today)</h3>
"""
            var issueTags = (lastSprintReport.completedIssues + lastSprintReport.incompletedIssues).map {
                String($0.summary.split(separator: "】")[0] + "】")
            }
            
            issueTags = Array(Set(issueTags))
            
            for issueTag in issueTags {
                var table =
                """
                <ul><li>\(issueTag)</li></ul>
                """
                
                let issues = (lastSprintReport.completedIssues + lastSprintReport.incompletedIssues).filter {
                    $0.summary.hasPrefix(issueTag)
                    }.map { $0.toRealmObject() }
                
                table.append(
"""
<table style="border-collapse:collapse">
<tr>
<td style="border:1px solid #B0B0B0" width=450>任务</td>
<td style="border:1px solid #B0B0B0" width=50>负责人</td>
<td style="border:1px solid #B0B0B0" width=50>优先级</td>
<td style="border:1px solid #B0B0B0" width=80>状态</td>
</tr>
"""
                )
                for issue in issues {
                    var priority = ""
                    var status = ""
                    
                    switch issue.priorityName {
                    case "低优先级", "最低优先级": priority = "💚"
                    case "默认优先级": priority = "💛"
                    case "最高优先级(立刻执行)", "高优先级": priority = "❤️"
                    default: priority = issue.priorityName
                    }
                    
                    switch issue.statusName {
                    case "Start": status = "🏁 (\(issue.statusName))"
                    case "完成": status = "✅"
                    default: status = issue.statusName
                    }
                    
                    table.append(
"""
<tr>
<td style="border:1px solid #B0B0B0"><a href="\(JiraAPI.prefix.rawValue + UserDefaults.get(by: .jiraDomain) + JiraAPI.issueWeb.rawValue + issue.key)">\(issue.summary)</a></td>
<td style="border:1px solid #B0B0B0">\(issue.assignee)</td>
<td style="border:1px solid #B0B0B0">\(priority)</td>
<td style="border:1px solid #B0B0B0">\(status)</td>
</tr>
"""
                    )
                }
                table.append("</table><br><br>")
                content.append(table)
            }
            
            // 下周数据
            MainViewModel.fetch { nextSprintReport, _ in
                content.append(
"""
<h2>下周工作预告</h2>
<h3>周期：\(nextSprintReport.startDate) ~ \(nextSprintReport.endDate)</h3>
"""
                )
                
                var issueTags = (nextSprintReport.completedIssues + nextSprintReport.incompletedIssues).map {
                    String($0.summary.split(separator: "】")[0] + "】")
                }
                
                issueTags = Array(Set(issueTags))
                
                for issueTag in issueTags {
                    var table =
                    """
                    <ul><li>\(issueTag)</li></ul>
                    """
                    
                    let issues = (nextSprintReport.completedIssues + nextSprintReport.incompletedIssues).filter {
                        $0.summary.hasPrefix(issueTag)
                        }.map { $0.toRealmObject() }
                    
                    table.append("""
<table style="border-collapse:collapse">
<tr>
<td style="border:1px solid #B0B0B0" width=450>任务</td>
<td style="border:1px solid #B0B0B0" width=50>负责人</td>
<td style="border:1px solid #B0B0B0" width=50>优先级</td>
<td style="border:1px solid #B0B0B0" width=80>状态</td>
</tr>
""")
                    for issue in issues {
                        var priority = ""
                        var status = ""
                        
                        switch issue.priorityName {
                        case "低优先级", "最低优先级": priority = "💚"
                        case "默认优先级": priority = "💛"
                        case "最高优先级(立刻执行)", "高优先级": priority = "❤️"
                        default: priority = issue.priorityName
                        }
                        
                        switch issue.statusName {
                        case "Start": status = "🏁 (\(issue.statusName))"
                        case "完成": status = "✅"
                        default: status = issue.statusName
                        }
                        
                        table.append(
"""
<tr>
<td style="border:1px solid #B0B0B0"><a href="\(JiraAPI.prefix.rawValue + UserDefaults.get(by: .jiraDomain) + JiraAPI.issueWeb.rawValue + issue.key)">\(issue.summary)</a></td>
<td style="border:1px solid #B0B0B0">\(issue.assignee)</td>
<td style="border:1px solid #B0B0B0">\(priority)</td>
<td style="border:1px solid #B0B0B0">\(status)</td>
</tr>
"""
                        )
                    }
                    table.append("</table><br><br>")
                    content.append(table)
                }
                
                content.append("<br><br><b>注：优先级顺序：高 -> 低 ❤️💛💚；状态：完成 ✅，开始 🏁，进行中为相应文字表述</b>")
                content.append("<br><hr><center><b>Powered by <a href=\"https://github.com/kingcos/Jirara\">Jirara</a> with ❤️</b></center>")
                
                completion(subject, content)
            }
        }
    }
    
    static func send() {
        
    }
}
