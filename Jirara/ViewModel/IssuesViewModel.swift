//
//  IssuesViewModel.swift
//  Jirara
//
//  Created by kingcos on 2018/12/7.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import RxSwift
import Moya

struct IssuesViewModel {
    struct Input {
        let menuOpened = PublishSubject<Void>()
    }
    
    struct Output {
        let issues = BehaviorSubject<[Issue]>(value: [])
    }
    
    let inputs = Input()
    let outputs = Output()
    
    private let bag = DisposeBag()
    
    init() {
        binding()
    }
    
    func binding() {
        let fetchRapidViewAction = inputs
            .menuOpened
            .flatMap {
                JiraAPIService
                    .provider
                    .rx
                    .request(.fetchRapidViewID)
                    .asObservable()
                    .mapModel(RapidViews.self)
                    .map { $0.views }
            }
            .flatMap {
                $0
                    .filter({ $0.name == UserDefaults.get(by: .scrumName) })
                    .first
                    .map(Observable.just) ?? Observable.empty()
            }
            .share()
        
        let fetchSprintAction = fetchRapidViewAction
            .flatMap {
                JiraAPIService
                    .provider
                    .rx
                    .request(.fetchSprintID(rapidViewID: $0.id))
                    .asObservable()
                    .mapModel(SprintQuery.self)
                    .map { $0.sprints }
            }
            .flatMap {
                $0
                    .filter { $0.state == "ACTIVE" }
                    .first
                    .map(Observable.just) ?? Observable.empty()
            }
            .share()
        
        Observable
            .zip(fetchRapidViewAction, fetchSprintAction)
            .flatMap {
                JiraAPIService
                    .provider
                    .rx
                    .request(.fetchSprintReport(rapidViewID: $0.0.id, sprintID: $0.1.id))
                    .asObservable()
                    .mapModel(SprintReport.self)
                    .map { $0.completedIssues + $0.incompletedIssues }
            }
            .flatMap {
                Observable
                    .zip($0.map {
                            JiraAPIService
                            .provider
                            .rx
                            .request(.fetchIssue(id: $0.id))
                            .asObservable()
                            .mapModel(Issue.self)
                            .asObservable()
                    })
            }
            .bind(to: outputs.issues)
            .disposed(by: bag)
    }
}
