//
//  SprintQuery.swift
//  Jirara
//
//  Created by kingcos on 2018/6/14.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import Mappable

/**
 API: https://jira.mobike.com/rest/greenhopper/1.0/sprintquery/80
 **/
struct Sprint: Mappable {
    var id: Int
    var name: String
    var state: String
    var startDate: String = ""
    var endDate: String = ""
    
    init(map: Mapper) throws {
        id = try map.from("id")
        name = try map.from("name")
        state = try map.from("state")
    }
}

struct SprintQuery: Mappable {
    var sprints: [Sprint]
    
    init(map: Mapper) throws {
        sprints = try map.from("sprints")
    }
}
