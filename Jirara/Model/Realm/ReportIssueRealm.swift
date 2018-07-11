//
//  ReportIssueRealm.swift
//  Jirara
//
//  Created by kingcos on 2018/6/15.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import RealmSwift

class ReportIssueRealm: Object {
    @objc dynamic var id = 0
    @objc dynamic var key = ""
    @objc dynamic var summary = ""
    @objc dynamic var priorityName = ""
    @objc dynamic var assignee = ""
    @objc dynamic var statusName = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override var description: String {
        var priority = ""
        var status = ""
        
        switch priorityName {
        case "低优先级", "最低优先级": priority = "💚"
        case "默认优先级": priority = "💛"
        case "最高优先级(立刻执行)", "高优先级": priority = "❤️"
        default: priority = priorityName
        }
        
        switch statusName {
        case "Start": status = "🏁 (\(statusName))"
        case "完成": status = "✅"
        default: status = statusName
        }
        
        return
"""
<tr>
<td style="border:1px solid #B0B0B0"><a href="\(JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.issueWeb.rawValue + key)">\(summary)</a></td>
<td style="border:1px solid #B0B0B0">\(priority)</td>
<td style="border:1px solid #B0B0B0">\(status)</td>
</tr>
"""
    }
}
