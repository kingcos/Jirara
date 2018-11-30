//
//  Transition.swift
//  Jirara
//
//  Created by kingcos on 2018/7/13.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import Mappable

/**
 API: /rest/api/2/issue/56848/transitions
 **/
struct Transitions: Mappable {
    var transitions: [Transition]
    
    init(map: Mapper) throws {
        transitions = try map.from("transitions")
    }
}

struct Transition: Mappable {
    var id: String
    var name: String
    
    init(map: Mapper) throws {
        id = try map.from("id")
        name = try map.from("name")
    }
}
