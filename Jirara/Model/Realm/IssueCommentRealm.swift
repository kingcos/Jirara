//
//  IssueCommentRealm.swift
//  Jirara
//
//  Created by kingcos on 2018/7/12.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import RealmSwift

class IssueCommentRealm: Object {
    @objc dynamic var id = ""
    @objc dynamic var author = ""
    @objc dynamic var content = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}

class IssueTransitionRealm: Object {
    @objc dynamic var id = ""
    @objc dynamic var name = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
}
