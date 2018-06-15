//
//  EngineerRealm.swift
//  Jirara
//
//  Created by kingcos on 2018/6/15.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import RealmSwift

class EngineerRealm: Object {
    @objc dynamic var name = ""
    @objc dynamic var emailAddress = ""
    @objc dynamic var avatarURL = ""
    @objc dynamic var displayName = ""
    
    let issues = List<IssueRealm>()
}
