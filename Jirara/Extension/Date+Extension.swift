//
//  Date+Extension.swift
//  Jirara
//
//  Created by kingcos on 2018/12/17.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation

extension Date {
    static var today: String {
        get {
            let formatter = DateFormatter()
            formatter.dateFormat = Constants.DateFormat
            return formatter.string(from: Date())
        }
    }
}
