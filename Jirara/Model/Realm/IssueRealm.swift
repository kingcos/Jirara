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
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    override var description: String {
        return
"""
<tr>
<td style="border:1px solid #B0B0B0">\(summary)</td>
<td style="border:1px solid #B0B0B0">\(priorityName)</td>
<td style="border:1px solid #B0B0B0">\(statusName)</td>
</tr>
"""
    }
}
