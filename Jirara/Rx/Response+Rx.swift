//
//  Response+Rx.swift
//  Jirara
//
//  Created by kingcos on 2018/12/8.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import Moya
import RxSwift
import Mappable

extension ObservableType where E == Response {
    public func mapModel<T: Mappable>(_ type: T.Type) -> Observable<T> {
        return flatMap { response -> Observable<T> in
            return Observable.just(response.mapModel(T.self))
        }
    }
}

extension Response {
    func mapModel<T: Mappable>(_ type: T.Type) -> T {
        guard let model = try? T(JSONData: data) else {
            fatalError()
        }
        return model
    }
}
