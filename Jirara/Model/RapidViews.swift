//
//  RapidViews.swift
//  Jirara
//
//  Created by kingcos on 2018/6/14.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import Mappable

/**
 API: /rest/greenhopper/1.0/rapidview
 **/
struct RapidView: Mappable {
    var id: Int
    var name: String
    
    init(map: Mapper) throws {
        id = try map.from("id")
        name = try map.from("name")
    }
}

extension RapidView: Comparable {
    static func < (lhs: RapidView, rhs: RapidView) -> Bool {
        return lhs.id < rhs.id
    }
    
    static func == (lhs: RapidView, rhs: RapidView) -> Bool {
        return lhs.id == rhs.id && lhs.name == rhs.name
    }
}

struct RapidViews: Mappable {
    var views: [RapidView]
    
    init(map: Mapper) throws {
        views = try map.from("views")
    }
}
