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
    @objc dynamic var id = 0
    @objc dynamic var summary = ""
    @objc dynamic var priorityName = ""
    @objc dynamic var assignee = ""
    @objc dynamic var statusName = ""
}
