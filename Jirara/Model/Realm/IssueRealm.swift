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
    @objc dynamic var parentSummary = ""
    
    let comments = List<IssueCommentRealm>()
    let subtasks = List<IssueRealm>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

extension IssueRealm {
    static let dao = RealmHelper<IssueRealm>()
    
    static func add(_ object: IssueRealm) {
        dao.add([object])
    }
}
