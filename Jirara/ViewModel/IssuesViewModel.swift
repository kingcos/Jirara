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
        let menuClosed = PublishSubject<Void>()
    }
    
    struct Output {
        let issues = PublishSubject<[Issue]>()
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
                Observable
                    .from(optional: $0
                        .filter({ $0.name == UserDefaults.get(by: .scrumName) })
                        .first)
            }
            .share()
        
        let fetchActiveSprintAction = fetchRapidViewAction
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
                Observable
                    .from(optional: $0
                        .filter { $0.state == "ACTIVE" }
                        .first)
            }
            .share()

        let fetchIssuesAction = Observable
            .zip(fetchRapidViewAction, fetchActiveSprintAction)
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
                    })
            }
            .catchErrorJustReturn([])
            .share()
        
        let fetchFullIssuesActions = Observable
            .merge(
                fetchIssuesAction,
                fetchIssuesAction
                    .map {
                        $0.flatMap {
                            $0.subtasks.compactMap { Int($0.id) }
                        }
                    }
                    .flatMap {
                        Observable
                            .zip($0.map {
                                JiraAPIService
                                    .provider
                                    .rx
                                    .request(.fetchIssue(id: $0))
                                    .asObservable()
                                    .mapModel(Issue.self)
                            })
                    }
            )
            .catchErrorJustReturn([])
            .share()

        let fetchTransitionsAction = fetchFullIssuesActions
            .map {
                $0.compactMap { Int($0.id) }
            }
            .flatMap {
                Observable
                    .zip(
                        $0.map {
                            JiraAPIService
                                .provider
                                .rx
                                .request(.fetchTransitions(id: $0))
                                .asObservable()
                                .mapModel(Transitions.self)
                        }
                    )
            }
            .catchErrorJustReturn([])
            .share()
        
        Observable
            .zip(fetchFullIssuesActions, fetchTransitionsAction)
            .flatMap { t -> Observable<[Issue]> in
                var issues = [Issue]()
                for i in 0..<t.0.count {
                    var issue = t.0[i]
                    issue.transitions = t.1[i].transitions
                    issues.append(issue)
                }

                return Observable.from(optional: issues)
            }
            .catchErrorJustReturn([])
            .bind(to: outputs.issues)
            .disposed(by: bag)
        
        inputs
            .menuClosed
            .subscribe(onNext: {
                // Do sth...
            })
            .disposed(by: bag)
    }
}
