//
//  Issue.swift
//  Jirara
//
//  Created by kingcos on 2018/6/14.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import Mappable

/**
 API: https://jira.mobike.com/rest/greenhopper/1.0/rapid/charts/sprintreport?rapidViewId=80&sprintId=1210
 **/
struct Issue: Mappable {
    var id: Int
    var summary: String
    var priorityName: String
    var assignee: String
    var statusName: String
    
    init(map: Mapper) throws {
        id = try map.from("id")
        summary = try map.from("summary")
        priorityName = try map.from("priorityName")
        assignee = try map.from("assignee")
        statusName = try map.from("statusName")
    }
}

extension Issue: Realmable {
    func toRealmObject() -> IssueRealm {
        let object = IssueRealm()
        object.id = id
        object.summary = summary
        object.priorityName = priorityName
        object.assignee = assignee
        object.statusName = statusName
        
        return object
    }
}
