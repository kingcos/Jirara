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
    
    static func send(_ type: SummaryType, _ completion: @escaping (String, String) -> Void) {
        switch type {
        case .team:
            sendTeam(completion)
        case .individual:
            sendIndividual(completion)
        }
    }
    
    static private func sendIndividual(_ completion: @escaping (String, String) -> Void) {
        func generateIndivitualList(_ content: inout String,
                                    _ issues: [Issue]) {
            issues.forEach { issue in
                content.append(
"""
\(issue.parentSummary == "" ? "- " + issue.summary : "    - " + issue.summary)

"""
                )
            }
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        
        MainViewModel.fetch(UserDefaults.get(by: .scrumName), false) { sprintReport, issues in
            guard let sprintReport = sprintReport else { fatalError() }
            let subject = "[周报] \(sprintReport.startDate) ~ \(sprintReport.endDate)"
            let today = formatter.string(from: Date())
            
            // 上周数据
            var content =
            """
            ## 本周工作
            
            > **周期：\(sprintReport.startDate) ~ \(sprintReport.endDate) 统计日期：\(today)**
            
            
            """
            generateIndivitualList(&content, issues.filter { $0.assignee == UserDefaults.get(by: .accountUsername) })
            
            MainViewModel.fetch(UserDefaults.get(by: .scrumName), true) { sprintReport, issues in
                guard let sprintReport = sprintReport else { fatalError() }
                content.append(
                    """
                    
                    ## 下周工作预告
                    
                    > **周期：\(sprintReport.startDate) ~ \(sprintReport.endDate)**
                    
                    
                    """
                )
                generateIndivitualList(&content, issues.filter { $0.assignee == UserDefaults.get(by: .accountUsername) })
                completion(subject, content)
            }
        }
    }

    /// 发送团队周报
    static func sendTeam(_ completion: @escaping (String, String) -> Void) {
        func generateTeamList(_ content: inout String,
                              _ issues: [Issue]) {
            let issueTypes = Array(Set(issues.map { $0.type })).sorted()
            for type in issueTypes {
                content.append(
                    """

- \(type)

<table style="border-collapse:collapse">
<tr><td width=600>任务</td><td width=180>负责人</td><td width=80>状态</td></tr>

"""
                )
                
                let specifiedIssues = issues.filter { $0.type == type }.sorted { $0.assignee < $1.assignee }
                for issue in specifiedIssues {
                    content.append(
"""
<tr><td>\(issue.summary)</td><td>\(issue.engineer?.displayName ?? issue.assignee)</td><td>\(issue.status)</td></tr>

"""
                    )
                    
//                    for subtask in issue.subtasks {
//                        let engineerName = EngineerRealmDAO.find(subtask.assignee).first?.displayName
//                        content.append(
//"""
//<tr><td>\("┗─ " + subtask.title)</td><td>\(engineerName ?? subtask.assignee)</td><td>\(subtask.status)</td></tr>
//
//"""
//                        )
//                    }
                }
                
                content.append("</table><br>\n")
            }
            content.append("<br>\n")
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = Constants.dateFormat
        
        // 上周
        MainViewModel.fetch(UserDefaults.get(by: .scrumName),
                            false) { sprintReport, issues in
                                guard let sprintReport = sprintReport else { fatalError() }
                                let subject = "iOS Engineers 团队周报 \(sprintReport.startDate) ~ \(sprintReport.endDate)"
                                let today = formatter.string(from: Date())
                                var content =
                                """
                                <style>
                                td { border:1px solid #B0B0B0 }
                                </style>
                                
                                <h2>iOS Engineers 本周团队工作报告</h2>
                                
                                <h3>周期：\(sprintReport.startDate) ~ \(sprintReport.endDate)\t统计日期：\(today)</h3>
                                
                                """
                                generateTeamList(&content, issues)
                                
                                MainViewModel.fetch(UserDefaults.get(by: .scrumName),
                                                    true) { sprintReport, issues in
                                                        guard let sprintReport = sprintReport else { fatalError() }
                                                        content.append(
                                                            """
                                                            
                                                            <h2>下周工作预告</h2>
                                                            
                                                            <h3>周期：\(sprintReport.startDate) ~ \(sprintReport.endDate)</h3>
                                                            
                                                            """
                                                        )
                                                        generateTeamList(&content, issues)
                                                        completion(subject, content)
                                }
                                
        }
    }
}
