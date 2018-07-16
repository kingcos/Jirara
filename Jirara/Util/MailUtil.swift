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
    
    static func send(_ type: SummaryType, _ completion: @escaping (String, String) -> Void) {
        if type == .team {
            sendTeam(completion)
        } else {
            sendIndividual(completion)
        }
    }
    
    static func sendIndividual(_ completion: @escaping (String, String) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat

        // 上周数据
        MainViewModel.fetch(Constants.RapidViewName, false) { lastSprintReport, issueRealms, engineerRealms in
            let engineerRealm = engineerRealms.filter { $0.name == UserDefaults.get(by: .accountUsername) }.first
            guard let engineer = engineerRealm else {
                return
            }
            let subject = "iOS - \(engineer.displayName)个人周报 \(lastSprintReport.startDate) ~ \(lastSprintReport.endDate)"
            let today = formatter.string(from: Date())
            
            var content =
"""
<h2>Mobike - iOS - \(engineer.displayName)本周个人工作报告</h2>
<h3>周期：\(lastSprintReport.startDate) ~ \(lastSprintReport.endDate)\t统计日期：\(today)</h3>
<table style="border-collapse:collapse">
<tr>
<td style="border:1px solid #B0B0B0" width=450>任务</td>
<td style="border:1px solid #B0B0B0" width=50>优先级</td>
<td style="border:1px solid #B0B0B0" width=80>状态</td>
<td style="border:1px solid #B0B0B0" width=80>进度</td>
</tr>
"""
            let issues = issueRealms.filter { $0.assignee == UserDefaults.get(by: .accountUsername) }
            for issue in issues {
                let progress = issue.comments.filter {
                    $0.content.hasPrefix(Constants.JiraIssueProgressPrefix)
                    }.first?.content.replacingOccurrences(of: Constants.JiraIssueProgressPrefix, with: "") ?? "-"
                var priority = ""
                var status = ""
                
                switch issue.priority {
                case "低优先级", "最低优先级": priority = "💚"
                case "默认优先级": priority = "💛"
                case "最高优先级(立刻执行)", "高优先级": priority = "❤️"
                default: priority = issue.priority
                }
                
                switch issue.status {
                case "Start": status = "🏁 (\(issue.status))"
                case "完成": status = "✅"
                default: status = issue.status
                }
                
                content.append(
"""
<tr>
<td style="border:1px solid #B0B0B0"><a href="\(JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.issueWeb.rawValue + issue.key)">\(issue.title)</a></td>
<td style="border:1px solid #B0B0B0">\(priority)</td>
<td style="border:1px solid #B0B0B0">\(status)</td>
<td style="border:1px solid #B0B0B0">\(progress)</td>
</tr>
""")
            }
            
            // 本周数据
            MainViewModel.fetch(Constants.RapidViewName) { nextSprintReport, issueRealms, _ in
                content.append(
"""
</table>
<br><br>
<h2>下周工作预告</h2>
<h3>周期：\(nextSprintReport.startDate) ~ \(nextSprintReport.endDate)</h3>
<table style="border-collapse:collapse">
<tr>
<td style="border:1px solid #B0B0B0" width=450>任务</td>
<td style="border:1px solid #B0B0B0" width=50>优先级</td>
<td style="border:1px solid #B0B0B0" width=80>状态</td>
<td style="border:1px solid #B0B0B0" width=80>进度</td>
</tr>
""")
                let issues = issueRealms.filter { $0.assignee == UserDefaults.get(by: .accountUsername) }
                for issue in issues {
                    let progress = issue.comments.filter {
                        $0.content.hasPrefix(Constants.JiraIssueProgressPrefix)
                        }.first?.content.replacingOccurrences(of: Constants.JiraIssueProgressPrefix, with: "") ?? "-"
                    var priority = ""
                    var status = ""

                    switch issue.priority {
                    case "低优先级", "最低优先级": priority = "💚"
                    case "默认优先级": priority = "💛"
                    case "最高优先级(立刻执行)", "高优先级": priority = "❤️"
                    default: priority = issue.priority
                    }

                    switch issue.status {
                    case "Start": status = "🏁 (\(issue.status))"
                    case "完成": status = "✅"
                    default: status = issue.status
                    }

                    content.append(
"""
<tr>
<td style="border:1px solid #B0B0B0"><a href="\(JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.issueWeb.rawValue + issue.key)">\(issue.title)</a></td>
<td style="border:1px solid #B0B0B0">\(priority)</td>
<td style="border:1px solid #B0B0B0">\(status)</td>
<td style="border:1px solid #B0B0B0">\(progress)</td>
</tr>
""")
                }

                content.append("</table><br><br><b>注：优先级顺序：高 -> 低 ❤️💛💚；状态：完成 ✅，开始 🏁，进行中为相应文字表述</b>")
                completion(subject, content)
            }
        }
    }

    static func sendTeam(_ completion: @escaping (String, String) -> Void) {
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        
        MainViewModel.fetch(Constants.RapidViewName, false) { lastSprintReport, issueRealms, engineerRealms in
            let subject = "iOS Engineers 团队周报 \(lastSprintReport.startDate) ~ \(lastSprintReport.endDate)"
            let today = formatter.string(from: Date())
            var content =
"""
<h2>Mobike - iOS Engineers 本周团队工作报告</h2>
<h3>周期：\(lastSprintReport.startDate) ~ \(lastSprintReport.endDate)\t统计日期：\(today)</h3>
"""
            let issueTypes = Array(Set(lastSprintReport.issues.map { $0.type }))
            for type in issueTypes {
                var table =
"""
<ul><li>\(type)</li></ul>
"""
                table.append(
"""
<table style="border-collapse:collapse">
<tr>
<td style="border:1px solid #B0B0B0" width=450>任务</td>
<td style="border:1px solid #B0B0B0" width=50>负责人</td>
<td style="border:1px solid #B0B0B0" width=50>优先级</td>
<td style="border:1px solid #B0B0B0" width=80>状态</td>
<td style="border:1px solid #B0B0B0" width=80>进度</td>
</tr>
""")
                let issues = issueRealms.filter { $0.type == type }
                for issue in issues {
                    let progress = issue.comments.filter {
                        $0.content.hasPrefix(Constants.JiraIssueProgressPrefix)
                        }.first?.content.replacingOccurrences(of: Constants.JiraIssueProgressPrefix, with: "") ?? "-"
                    var priority = ""
                    var status = ""

                    switch issue.priority {
                    case "低优先级", "最低优先级": priority = "💚"
                    case "默认优先级": priority = "💛"
                    case "最高优先级(立刻执行)", "高优先级": priority = "❤️"
                    default: priority = issue.priority
                    }

                    switch issue.status {
                    case "Start": status = "🏁 (\(issue.status))"
                    case "完成": status = "✅"
                    default: status = issue.status
                    }

                    table.append(
"""
<tr>
<td style="border:1px solid #B0B0B0"><a href="\(JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.issueWeb.rawValue + issue.key)">\(issue.title)</a></td>
<td style="border:1px solid #B0B0B0">\(issue.assignee)</td>
<td style="border:1px solid #B0B0B0">\(priority)</td>
<td style="border:1px solid #B0B0B0">\(status)</td>
<td style="border:1px solid #B0B0B0">\(progress)</td>
</tr>
""")
                }
                table.append("</table><br><br>")
                content.append(table)
            }

            // 下周数据
            MainViewModel.fetch(Constants.RapidViewName) { nextSprintReport, issueRealms, _ in
                content.append(
"""
<h2>下周工作预告</h2>
<h3>周期：\(nextSprintReport.startDate) ~ \(nextSprintReport.endDate)</h3>
"""
                )

                let issueTypes = Array(Set(nextSprintReport.issues.map { $0.type }))
                for type in issueTypes {
                    var table =
                    """
                    <ul><li>\(type)</li></ul>
                    """
                    table.append(
                        """
<table style="border-collapse:collapse">
<tr>
<td style="border:1px solid #B0B0B0" width=450>任务</td>
<td style="border:1px solid #B0B0B0" width=50>负责人</td>
<td style="border:1px solid #B0B0B0" width=50>优先级</td>
<td style="border:1px solid #B0B0B0" width=80>状态</td>
<td style="border:1px solid #B0B0B0" width=80>进度</td>
</tr>
""")
                    let issues = issueRealms.filter { $0.type == type }
                    for issue in issues {
                        let progress = issue.comments.filter {
                            $0.content.hasPrefix(Constants.JiraIssueProgressPrefix)
                            }.first?.content.replacingOccurrences(of: Constants.JiraIssueProgressPrefix, with: "") ?? "-"
                        var priority = ""
                        var status = ""
                        
                        switch issue.priority {
                        case "低优先级", "最低优先级": priority = "💚"
                        case "默认优先级": priority = "💛"
                        case "最高优先级(立刻执行)", "高优先级": priority = "❤️"
                        default: priority = issue.priority
                        }
                        
                        switch issue.status {
                        case "Start": status = "🏁 (\(issue.status))"
                        case "完成": status = "✅"
                        default: status = issue.status
                        }
                        
                        table.append(
                            """
                            <tr>
                            <td style="border:1px solid #B0B0B0"><a href="\(JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.issueWeb.rawValue + issue.key)">\(issue.title)</a></td>
                            <td style="border:1px solid #B0B0B0">\(issue.assignee)</td>
                            <td style="border:1px solid #B0B0B0">\(priority)</td>
                            <td style="border:1px solid #B0B0B0">\(status)</td>
                            <td style="border:1px solid #B0B0B0">\(progress)</td>
                            </tr>
                            """
                        )
                    }
                    table.append("</table><br><br>")
                    content.append(table)
                }
                content.append("<br><br><b>注：优先级顺序：高 -> 低 ❤️💛💚；状态：完成 ✅，开始 🏁，进行中为相应文字表述</b>")

                completion(subject, content)
            }
        }
    }
}
