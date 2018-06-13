//
//  UserDefaults+Extension.swift
//  Jirara
//
//  Created by kingcos on 2018/6/13.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation

extension UserDefaults {
    /// UserDefaults key enum for safety
    enum UserDefaultsKey: String {
        case jiraDomain = "com.maimieng.jirara.jiraDomain"
        case username = "con.maimieng.jirara.username"
        case userAuth = "com.maimieng.jirara.userAuth"
        case userEmail = "com.maimieng.jirara.userEmail"
    }
    
    /// Save to UserDefaults by key
    ///
    /// - Parameter value: Value to save, key: UserDefaults key enum
    class func save(_ value: Any, for key: UserDefaultsKey) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    /// Get string value from UserDefaults by key
    ///
    /// - Parameter key: UserDefaults key enum
    class func get(by key: UserDefaultsKey) -> String {
        return UserDefaults.standard.string(forKey: key.rawValue) ?? ""
    }
}
