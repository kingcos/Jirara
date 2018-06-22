//
//  Mail.swift
//  Jirara
//
//  Created by kingcos on 2018/6/21.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation

struct Mail {
    var from: EmailAddress
    var to: [EmailAddress]
    var cc: [EmailAddress]
    var subject: String
    var content: String
}

struct EmailAddress {
    var value: String
}
