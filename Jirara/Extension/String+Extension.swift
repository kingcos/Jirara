//
//  String+Extension.swift
//  Jirara
//
//  Created by kingcos on 2018/6/13.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation

extension String {
    /// The value after encoding by Base64
    var base64Encoded: String {
        get {
            guard let data = data(using: .utf8) else {
                fatalError("String should be UTF-8 format.")
            }
            let encoded = data.base64EncodedString().filter { $0 != "=" }
            
            return encoded
        }
    }
    
    func matchedByRegex(_ regex: String) -> String? {
        let content = self
        guard let regex = try? NSRegularExpression(pattern: regex,
                                                   options: .caseInsensitive) else { return nil }
        let nsContent = self as NSString
        return regex.matches(in: content, options: [], range: NSRange(location: 0, length: content.count)).map {
            nsContent.substring(with: $0.range)
        }.first
    }
    
}
