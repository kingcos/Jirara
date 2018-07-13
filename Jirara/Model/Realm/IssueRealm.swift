//
//  IssueRealm.swift
//  Jirara
//
//  Created by kingcos on 2018/6/15.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import RealmSwift

class IssueRealm: Object {
    @objc dynamic var id = ""
    @objc dynamic var key = ""
    @objc dynamic var type = ""
    @objc dynamic var title = ""
    @objc dynamic var priority = ""
    @objc dynamic var assignee = ""
    @objc dynamic var status = ""
    
    let comments = List<IssueCommentRealm>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override var description: String {
        return ""
//        var priority = ""
//        var status = ""
//
//        switch priorityName {
//        case "低优先级", "最低优先级": priority = "💚"
//        case "默认优先级": priority = "💛"
//        case "最高优先级(立刻执行)", "高优先级": priority = "❤️"
//        default: priority = priorityName
//        }
//
//        switch statusName {
//        case "Start": status = "🏁 (\(statusName))"
//        case "完成": status = "✅"
//        default: status = statusName
//        }
//
//        return
//"""
//<tr>
//<td style="border:1px solid #B0B0B0"><a href="\(JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.issueWeb.rawValue + key)">\(summary)</a></td>
//<td style="border:1px solid #B0B0B0">\(priority)</td>
//<td style="border:1px solid #B0B0B0">\(status)</td>
//</tr>
//"""
    }
}

extension IssueRealm {
    static let dao = RealmHelper<IssueRealm>()
    
    static func add(_ object: IssueRealm) {
        dao.add([object])
    }
}
