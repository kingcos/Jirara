//
//  UserDefaults+Extension.swift
//  Jirara
//
//  Created by kingcos on 2018/6/13.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation

extension UserDefaults {
    enum UserDefaultsKey: String {
        case jiraDomain = "com.maimieng.jirara.jiraDomain"
        case username = "con.maimieng.jirara.username"
        case userAuth = "com.maimieng.jirara.userAuth"
        case userEmail = "com.maimieng.jirara.userEmail"
    }
    
    class func save(_ stringValue: Any, for key: UserDefaultsKey) {
        UserDefaults.standard.set(stringValue, forKey: key.rawValue)
    }
    
    class func get(by key: UserDefaultsKey) -> String {
        return UserDefaults.standard.string(forKey: key.rawValue) ?? ""
    }
}
