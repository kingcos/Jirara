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
    
    func update(_ property: String, _ object: T, _ completion: (_ object: T) -> Void) {
        let objects = realm.objects(T.self).filter("\(property) = %@", object)
        
        if let obj = objects.first {
            do {
                try realm.write {
                    completion(obj)
                }
            } catch(let error) {
                print((error as NSError).description)
            }
        }
    }
    
    func findAll() -> Results<T> {
        return realm.objects(T.self)
    }
}
