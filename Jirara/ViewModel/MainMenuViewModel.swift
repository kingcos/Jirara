//
//  MainMenuViewModel.swift
//  Jirara
//
//  Created by kingcos on 2018/12/7.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import RxSwift
import Moya

struct MainMenuViewModel {
    struct Input {
        let menuOpened = PublishSubject<Void>()
        let menuClosed = PublishSubject<Void>()
        let clickOnTransition = PublishSubject<(String, String)>()
        let clickOnViewDetails = PublishSubject<String>()
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
                    .from(optional: $0.first { $0.name == UserDefaults.get(by: .scrumName) })
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
                    .from(optional: $0.first { $0.state == "ACTIVE" })
            }
            .share()

        let fetchIssuesAction = Observable
            .zip(fetchRapidViewAction, fetchActiveSprintAction)
            .flatMap {
                JiraAPIService
                    .provider
                    .rx
                    .request(.fetchSprintReport(rapidViewID: $0.0.id,
                                                sprintID: $0.1.id))
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
        
        let fetchIssuesAndSubissuesActions = Observable
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
            .map { $0.sorted() }
            .catchErrorJustReturn([])
            .share()

        let fetchTransitionsAction = fetchIssuesAndSubissuesActions
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
        
        let fetchIssueWithTransitionsAction = Observable
            .zip(fetchIssuesAndSubissuesActions, fetchTransitionsAction)
            .flatMap { t -> Observable<[Issue]> in
                var issues = [Issue]()
                for i in 0..<t.0.count {
                    var issue = t.0[i]
                    issue.transitions = t.1[i].transitions
                    issues.append(issue)
                }

                return Observable.from(optional: issues.sorted())
            }
            .distinctUntilChanged({ $0 == $1 })
            .catchErrorJustReturn([])
            .share()
        
        fetchIssueWithTransitionsAction
            .bind(to: outputs.issues)
            .disposed(by: bag)
        
        inputs
            .menuClosed
            .subscribe(onNext: {
                // Do sth...
            })
            .disposed(by: bag)
        
        Observable
            .zip(inputs.clickOnTransition.asObservable(), fetchIssueWithTransitionsAction)
            .flatMap { t -> Observable<(String?, String?)> in
                let issueID = t.1.first { $0.summary == t.0.0 }?.id
                let transionID = t.1.first { $0.summary == t.0.0 }?.transitions.first { $0.name == t.0.1 }?.id
                return Observable.just((issueID, transionID))
            }
            .flatMap {
                Observable.just((Int($0.0 ?? "-1") ?? -1, Int($0.1 ?? "-1") ?? -1))
            }
            .subscribe(onNext: {
                JiraAPIService
                    .provider
                    .request(.updateIssueTransition(issueID: $0.0, transitionID: $0.1)) { _ in }
            })
            .disposed(by: bag)
        
        Observable
            .zip(inputs.clickOnViewDetails.asObservable(), fetchIssueWithTransitionsAction)
            .flatMap { t -> Observable<String> in
                Observable.from(optional: t.1.first { $0.summary == t.0 }?.key)
            }
            .subscribe(onNext: {
                if let url = URL(string: UserDefaults.get(by: .accountJiraDomain) + "/browse/" + $0) {
                    NSWorkspace.shared.open(url)
                }
            })
            .disposed(by: bag)
    }
}
