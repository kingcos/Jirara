//
//  MainMenuViewModel.swift
//  Jirara
//
//  Created by kingcos on 2018/12/7.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import RxSwift

struct MainMenuModel {
    struct Input {
        let fetchIssues = PublishSubject<Void>()
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
    }
}
