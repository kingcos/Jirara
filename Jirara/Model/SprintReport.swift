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
    var completedIssues: [Issue]
    var incompletedIssues: [Issue]
    var startDate: String
    var endDate: String
    
    init(map: Mapper) throws {
        completedIssues = try map.from("contents.completedIssues")
        incompletedIssues = try map.from("contents.issuesNotCompletedInCurrentSprint")
        startDate = try map.from("sprint.startDate")
        endDate = try map.from("sprint.endDate")
    }
}
