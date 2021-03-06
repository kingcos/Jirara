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
 API: /rest/greenhopper/1.0/rapid/charts/sprintreport?rapidViewId=80&sprintId=1210
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
        
        startDate = formatDate(startDate)
        endDate = formatDate(endDate)
    }
}

struct ReportIssue: Mappable {
    var id: Int
    var key: String
    var summary: String
    var priorityName: String?
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
}

extension SprintReport {
    func formatDate(_ origin: String) -> String {
        // 15/06/18 dd/mm/yy
        // 26/十一月/18 9:00 上午
        guard origin.split(separator: "/").count > 2 else { return origin }
        let chineseMonth = String(origin.split(separator: "/")[1])
        
        guard Constants.MonthNumberDict.keys.contains(chineseMonth) else { return origin }
        let numberMonth = Constants.MonthNumberDict[chineseMonth]
        
        let substrings = origin.replacingOccurrences(of: chineseMonth, with: numberMonth ?? "").split(separator: " ")
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yy"
        let date = formatter.date(from: String(substrings[0])) ?? Date()
        
        formatter.dateFormat = Constants.DateFormat
        return formatter.string(from: date)
    }
}
