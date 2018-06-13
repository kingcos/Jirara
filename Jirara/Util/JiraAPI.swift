//
//  JiraAPI.swift
//  Jirara
//
//  Created by kingcos on 2018/6/13.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation

enum JiraAPI: String {
    // 前缀
    case prefix = "https://"
    case myself = "/rest/api/2/myself"
    case rapidViews = "/rest/greenhopper/1.0/rapidview"
    case sprints = "/rest/greenhopper/1.0/sprintquery/"
    case sprintReport = "/rest/greenhopper/1.0/rapid/charts/sprintreport?rapidViewId=80&sprintId=1210"
}
