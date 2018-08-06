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
        
        // Account
        case accountJiraDomain = "com.maimieng.jirara.account.jira-domain"
        case accountUsername = "com.maimieng.jirara.account.username"
        case accountPassword = "com.maimieng.jirara.account.password"
        case accountAuth = "com.maimieng.jirara.account.auth"
        
        // E-mail
        case emailSMTP = "com.maimieng.jirara.email.smtp"
        case emailAddress = "com.maimieng.jirara.email.address"
        case emailPassword = "com.maimieng.jirara.email.password"
        case emailAccountUniversalState = "com.maimieng.jirara.email.account.universal.state"
        case emailPort = "com.maimieng.jirara.email.port"
        case emailTo = "com.maimieng.jirara.to"
        case emailCc = "com.maimieng.jirara.cc"
        
        // Timer
        case jiraTimerSwitch = "com.maimieng.jirara.jira.timer.switch"
    }
    
    /// Save to UserDefaults by key
    ///
    /// - Parameter value: Value to save, key: UserDefaults key enum
    class func save(_ value: String, for key: UserDefaultsKey) {
        UserDefaults.standard.set(value, forKey: key.rawValue)
    }
    
    /// Get string value from UserDefaults by key
    ///
    /// - Parameter key: UserDefaults key enum
    class func get(by key: UserDefaultsKey) -> String {
        return UserDefaults.standard.string(forKey: key.rawValue) ?? ""
    }
}
