//
//  SprintReport.swift
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
struct SprintReport: Mappable {
    var id: Int
    var completedIssues: [ReportIssue]
    var incompletedIssues: [ReportIssue]
    var startDate: String
    var endDate: String
    
    init(map: Mapper) throws {
        id = try map.from("sprint.id")
        completedIssues = try map.from("contents.completedIssues")
        incompletedIssues = try map.from("contents.issuesNotCompletedInCurrentSprint")
        startDate = try map.from("sprint.startDate")
        endDate = try map.from("sprint.endDate")
    }
}

struct ReportIssue: Mappable, Realmable {
    var id: Int
    var key: String
    var summary: String
    var priorityName: String
    var assignee: String
    var statusName: String
    
    init(map: Mapper) throws {
        id = try map.from("id")
        key = try map.from("key")
        summary = try map.from("summary")
        priorityName = try map.from("priorityName")
        assignee = try map.from("assignee")
        statusName = try map.from("statusName")
    }
    
    func toRealmObject() -> IssueRealm {
        let object = IssueRealm()
        
        object.id = String(id)
        object.key = key
        object.type = String(summary.split(separator: "】")[0] + "】")
        object.title = summary.replacingOccurrences(of: object.type, with: "")
        object.priority = priorityName
        object.assignee = assignee
        object.status = statusName
        
        return object
    }
}

extension SprintReport: Realmable {
    func toRealmObject() -> SprintReportRealm {
        let object = SprintReportRealm()
        
        object.id = id
        object.startDate = formatDate(startDate)
        object.endDate = formatDate(endDate)
        object.issues.append(objectsIn: (completedIssues + incompletedIssues).map { $0.toRealmObject() })
        
        return object
    }
    
    func formatDate(_ origin: String) -> String {
        // 15/06/18 dd/mm/yy
        let chineseMonth = origin.split(separator: "/")[1]
        let numberMonth = Constants.MonthNumberDict[String(chineseMonth)]
        let substrings = origin.replacingOccurrences(of: chineseMonth, with: numberMonth ?? "").split(separator: " ")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        let date = formatter.date(from: String(substrings[0])) ?? Date()
        
        formatter.dateFormat = Constants.dateFormat
        return formatter.string(from: date)
    }
}
