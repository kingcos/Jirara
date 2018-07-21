//
//  Realmable.swift
//  Jirara
//
//  Created by kingcos on 2018/6/19.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import RealmSwift

protocol Realmable {
    associatedtype T: Object
    
    func toRealmObject() -> T
}
