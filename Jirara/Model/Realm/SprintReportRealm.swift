//
//  SprintReportRealm.swift
//  Jirara
//
//  Created by kingcos on 2018/6/15.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import RealmSwift

class SprintReportRealm: Object {
    @objc dynamic var id = 0
    @objc dynamic var startDate = ""
    @objc dynamic var endDate = ""
    
    let issues = List<ReportIssueRealm>()
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class SprintReportRealmDAO {
    static let dao = RealmHelper<SprintReportRealm>()
    
    static func add(_ object: SprintReportRealm) {
        dao.add([object])
    }
    
    static func findLatest() -> SprintReportRealm? {
        let all = dao.findAll().sorted { $0.id < $1.id }
        if all.count > 0 {
            return all[all.count - 1]
        }
        return nil
    }
    
    static func findLastLatest() -> SprintReportRealm? {
        let all = dao.findAll().sorted { $0.id < $1.id }
        if all.count > 1 {
            return all[all.count - 2]
        }
        return nil
    }
}
