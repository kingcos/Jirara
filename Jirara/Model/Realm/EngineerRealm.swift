//
//  EngineerRealm.swift
//  Jirara
//
//  Created by kingcos on 2018/6/15.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import RealmSwift

class EngineerRealm: Object {
    @objc dynamic var name = ""
    @objc dynamic var emailAddress = ""
    @objc dynamic var avatarURL = ""
    @objc dynamic var displayName = ""
    
//    let issues = List<IssueRealm>()
    
    override static func primaryKey() -> String? {
        return "name"
    }
    
    override var description: String {
        return ""
//        let issuesDesc = issues.reduce(
//"""
//<tr>
//<td style="border:1px solid #B0B0B0" width=500>任务</td>
//<td style="border:1px solid #B0B0B0" width=50>优先级</td>
//<td style="border:1px solid #B0B0B0" width=80>状态</td>
//</tr>
//""") { result, issue -> String in
//            result + issue.description
//        }
//        return
//"""
//<ul><li>\(displayName)</li></ul>
//<table style="border-collapse:collapse">
//\(issuesDesc)
//</table>
//<br><br>
//"""
    }
}

class EngineerRealmDAO {
    static let dao = RealmHelper<EngineerRealm>()
    
    static func add(_ object: EngineerRealm) {
        dao.add([object])
    }
    
    static func findAll() -> [EngineerRealm] {
        return dao.findAll().map { EngineerRealm(value: $0) }
    }
}
