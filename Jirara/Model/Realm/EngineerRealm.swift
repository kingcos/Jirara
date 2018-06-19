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
    
    let issues = List<IssueRealm>()
    
    override static func primaryKey() -> String? {
        return "name"
    }
}

class EngineerRealmDAO {
    static let dao = RealmHelper<EngineerRealm>()
    
    static func add(_ objects: [EngineerRealm]) {
        dao.add(objects)
    }
    
    static func findAll() -> [EngineerRealm] {
        return dao.findAll().map { EngineerRealm(value: $0) }
    }
}
