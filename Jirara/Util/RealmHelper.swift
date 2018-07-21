//
//  RealmHelper.swift
//  Jirara
//
//  Created by kingcos on 2018/6/19.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import RealmSwift

class RealmHelper<T: Object> {
    let realm: Realm
    
    init() {
        try! realm = Realm()
        
        defer {
            realm.invalidate()
        }
    }
    
    func add(_ objects: [T], isUpdated: Bool = true) {
        do {
            try realm.write {
                realm.add(objects, update: isUpdated)
            }
        } catch(let error) {
            print((error as NSError).description)
        }
    }
    
    func findAll() -> Results<T> {
        return realm.objects(T.self)
    }
}
