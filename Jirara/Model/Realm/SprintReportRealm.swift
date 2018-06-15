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
    @objc dynamic var startDate = ""
    @objc dynamic var endDate = ""
    
    let compeletedIssues = List<IssueRealm>()
    let incompletedIssues = List<IssueRealm>()
}
