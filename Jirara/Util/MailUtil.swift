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
        MainViewModel.fetch(Constants.RapidViewName, false) {
            MainViewModel.fetch(Constants.RapidViewName) {
                if type == .team {
                    sendTeam(completion)
                } else {
                    sendIndividual(completion)
                }
            }
        }
    }
    
    static func sendIndividual(_ completion: @escaping (String, String) -> Void) {
        func generateIndivitualList(_ content: inout String,
                                    _ issues: [IssueRealm]) {
            content.append(
"""
<table style="border-collapse:collapse">
<tr>
<td style="border:1px solid #B0B0B0" width=450>任务</td>
<td style="border:1px solid #B0B0B0" width=50>优先级</td>
<td style="border:1px solid #B0B0B0" width=80>状态</td>
<td style="border:1px solid #B0B0B0" width=80>进度</td>
</tr>
"""
            )
            
            issues.forEach { issue in
                let progress = issue.comments.filter {
                    $0.content.hasPrefix(Constants.JiraIssueProgressPrefix)
                    }.first?.content.replacingOccurrences(of: Constants.JiraIssueProgressPrefix, with: "") ?? "-"
                content.append(
"""
<tr>
<td style="border:1px solid #B0B0B0">\(issue.parentSummary == "" ? issue.title : "┗─ " + issue.title)</td>
<td style="border:1px solid #B0B0B0">\(emojiIssuePrioriy(issue.priority))</td>
<td style="border:1px solid #B0B0B0">\(emojiIssueStatus(issue.status))</td>
<td style="border:1px solid #B0B0B0">\(progress)</td>
</tr>
"""
                )
            }
            content.append("</table><br>")
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat

        let engineers = EngineerRealmDAO.findAll().filter { $0.name == UserDefaults.get(by: .accountUsername) }
        guard let lastSprintReport = SprintReportRealmDAO.findLastLatest(),
              let engineer = engineers.first else { return }

        var lastIssues = [IssueRealm]()
        lastSprintReport.issues.forEach { issue in
            lastIssues.append(issue)
            issue.subtasks.forEach { subtask in
                lastIssues.append(subtask)
            }
        }
        lastIssues = lastIssues.filter { $0.assignee == UserDefaults.get(by: .accountUsername) }

        let subject = "iOS - \(engineer.displayName)个人周报 \(lastSprintReport.startDate) ~ \(lastSprintReport.endDate)"
        let today = formatter.string(from: Date())

        // 上周数据
        var content =
"""
<h2>Mobike - iOS - \(engineer.displayName)本周个人工作报告</h2>
<h3>周期：\(lastSprintReport.startDate) ~ \(lastSprintReport.endDate)\t统计日期：\(today)</h3>
"""
        generateIndivitualList(&content, lastIssues)
        
        // 下周数据
        guard let nextSprintReport = SprintReportRealmDAO.findLatest() else { return }
        
        var nextIssues = [IssueRealm]()
        nextSprintReport.issues.forEach { issue in
            nextIssues.append(issue)
            issue.subtasks.forEach { subtask in
                nextIssues.append(subtask)
            }
        }
        nextIssues = nextIssues.filter { $0.assignee == UserDefaults.get(by: .accountUsername) }
        
        content.append(
"""
</table>
<br><br>
<h2>下周工作预告</h2>
<h3>周期：\(nextSprintReport.startDate) ~ \(nextSprintReport.endDate)</h3>
"""
        )
        
        generateIndivitualList(&content, nextIssues)
        
        content.append("<hr><b style=\"font-size:80%\">注：优先级顺序：高 -> 低 ❤️💛💚；状态：完成 ✅，开始 🏁，进行中为相应文字表述</b>")
        completion(subject, content)
    }

    static func sendTeam(_ completion: @escaping (String, String) -> Void) {
        func generateTeamList(_ content: inout String,
                              _ issues: [IssueRealm]) {
            let issueTypes = Array(Set(issues.map { $0.type }))
            
            for type in issueTypes {
                content.append(
                    """
<ul><li>\(type)</li></ul>
<table style="border-collapse:collapse">
<tr>
<td style="border:1px solid #B0B0B0" width=450>任务</td>
<td style="border:1px solid #B0B0B0" width=50>负责人</td>
<td style="border:1px solid #B0B0B0" width=50>优先级</td>
<td style="border:1px solid #B0B0B0" width=80>状态</td>
<td style="border:1px solid #B0B0B0" width=80>进度</td>
</tr>
"""
                )
                
                let specifiedIssues = issues.filter { $0.type == type }
                
                for issue in specifiedIssues {
                    let progress = issue.comments.filter {
                        $0.content.hasPrefix(Constants.JiraIssueProgressPrefix)
                        }.first?.content.replacingOccurrences(of: Constants.JiraIssueProgressPrefix, with: "") ?? "-"

                    content.append(
"""
<tr>
<td style="border:1px solid #B0B0B0">\(issue.title)</td>
<td style="border:1px solid #B0B0B0">\(issue.assignee)</td>
<td style="border:1px solid #B0B0B0">\(emojiIssuePrioriy(issue.priority))</td>
<td style="border:1px solid #B0B0B0">\(emojiIssueStatus(issue.status))</td>
<td style="border:1px solid #B0B0B0">\(progress)</td>
</tr>
"""
                    )
                    
                    for subtask in issue.subtasks {
                        let progress = subtask.comments.filter {
                            $0.content.hasPrefix(Constants.JiraIssueProgressPrefix)
                            }.first?.content.replacingOccurrences(of: Constants.JiraIssueProgressPrefix, with: "") ?? "-"
                        
                        content.append(
"""
<tr>
<td style="border:1px solid #B0B0B0">\("┗─ " + subtask.title)</td>
<td style="border:1px solid #B0B0B0">\(subtask.assignee)</td>
<td style="border:1px solid #B0B0B0">\(emojiIssuePrioriy(subtask.priority))</td>
<td style="border:1px solid #B0B0B0">\(emojiIssueStatus(subtask.status))</td>
<td style="border:1px solid #B0B0B0">\(progress)</td>
</tr>
"""
                        )
                    }
                }
                
                content.append("</table><br>")
            }
            content.append("<br>")
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        
        // 上周
        guard let lastSprintReport = SprintReportRealmDAO.findLastLatest() else { return }
        
        let subject = "iOS Engineers 团队周报 \(lastSprintReport.startDate) ~ \(lastSprintReport.endDate)"
        let today = formatter.string(from: Date())
        
        var content =
"""
<h2>Mobike - iOS Engineers 本周团队工作报告</h2>
<h3>周期：\(lastSprintReport.startDate) ~ \(lastSprintReport.endDate)\t统计日期：\(today)</h3>
"""
        generateTeamList(&content, lastSprintReport.issues.map { $0 })

        // 下周数据
        guard let nextSprintReport = SprintReportRealmDAO.findLatest() else { return }
        
        content.append(
"""
<h2>下周工作预告</h2>
<h3>周期：\(nextSprintReport.startDate) ~ \(nextSprintReport.endDate)</h3>
"""
        )
        
        generateTeamList(&content, nextSprintReport.issues.map { $0 })
        
        content.append("<hr><b style=\"font-size:80%\">注：优先级顺序：高 -> 低 ❤️💛💚；状态：完成 ✅，开始 🏁，进行中为相应文字表述</b>")
        completion(subject, content)
    }
    
    static func emojiIssuePrioriy(_ priority: String) -> String {
        switch priority {
        case "低优先级", "最低优先级":
            return "💚"
        case "默认优先级":
            return "💛"
        case "最高优先级(立刻执行)", "高优先级":
            return "❤️"
        default:
            return priority
        }
    }
    
    static func emojiIssueStatus(_ status: String) -> String {
        switch status {
        case "Start":
            return "🏁 (\(status))"
        case "完成":
            return "✅"
        default:
            return status
        }
    }
}
