//
//  JiraAPI.swift
//  Jirara
//
//  Created by kingcos on 2018/6/13.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation

enum JiraAPI: String {
    case prefix = "https://"
    
    case rapidView = "/rest/greenhopper/1.0/rapidview"
    case sprintQuery = "/rest/greenhopper/1.0/sprintquery/"
    case sprintReport = "/rest/greenhopper/1.0/rapid/charts/sprintreport"
    case user = "/rest/api/2/user"
    case issue = "/rest/api/2/issue/"
    case transitions = "/transitions"
}
