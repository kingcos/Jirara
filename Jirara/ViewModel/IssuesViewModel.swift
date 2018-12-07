//
//  IssuesViewModel.swift
//  Jirara
//
//  Created by kingcos on 2018/12/7.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import RxSwift

struct IssuesViewModel {
    struct Input {
        let startFetchIssues = PublishSubject<Void>()
        let endFetchIssues = PublishSubject<Void>()
        let menuOpened = PublishSubject<Void>()
        let menuClosed = PublishSubject<Void>()
    }
    
    struct Output {
        let issues = BehaviorSubject<[Issue]>(value: [])
    }
    
    let inputs = Input()
    let outputs = Output()
    
    private let bag = DisposeBag()
    
    init() {
        let startFetchIssuesAction = inputs
            .startFetchIssues
            .do(onNext: {
                self.outputs.issues.onNext([])
            })
            .flatMap()

        let menuOpenAction = inputs
            .menuOpen
            .flatMapLatest { isMenuOpen in

        }
    }
}
