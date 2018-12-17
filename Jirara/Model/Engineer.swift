//
//  Engineer.swift
//  Jirara
//
//  Created by kingcos on 2018/6/13.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import Mappable

/**
 API: /rest/api/2/user?username=i-maiming
 **/
struct Engineer: Mappable {
    var name: String
    var emailAddress: String
    var avatarURL: String
    var displayName: String
    var issues: [Issue] = []
    
    init(map: Mapper) throws {
        name = try map.from("name")
        emailAddress = try map.from("emailAddress")
        avatarURL = try map.from("avatarUrls.48x48")
        displayName = try map.from("displayName")
    }
}

extension Engineer: Comparable {
    static func < (lhs: Engineer, rhs: Engineer) -> Bool {
        return lhs.name < rhs.name
    }
    
    static func == (lhs: Engineer, rhs: Engineer) -> Bool {
        let result = lhs.name == rhs.name
            && lhs.emailAddress == rhs.emailAddress
            && lhs.avatarURL == rhs.avatarURL
            && lhs.issues == rhs.issues
        return result
    }
}
