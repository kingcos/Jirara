//
//  ScrumsViewModel.swift
//  Jirara
//
//  Created by kingcos on 2018/12/9.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import RxSwift
import Moya

struct ScrumsViewModel {
    struct Input {
        let fetchTeamScrums = PublishSubject<Void>()
    }
    
    struct Output {
        let activeScrum = BehaviorSubject<SprintReport?>(value: nil)
        let activeIssues = BehaviorSubject<[Issue]>(value: [])
        
        let latestInactiveScrum = BehaviorSubject<SprintReport?>(value: nil)
        let latestInactiveIssues = BehaviorSubject<[Issue]>(value: [])
    }
    
    let inputs = Input()
    let outputs = Output()
    
    private let bag = DisposeBag()
    
    init() {
        binding()
    }
    
    func binding() {
        let fetchRapidViewAction = inputs
            .fetchTeamScrums
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
        
        let fetchSprintReportAction = Observable
            .zip(fetchRapidViewAction, fetchActiveSprintAction)
            .flatMap {
                JiraAPIService
                    .provider
                    .rx
                    .request(.fetchSprintReport(rapidViewID: $0.0.id, sprintID: $0.1.id))
                    .asObservable()
                    .mapModel(SprintReport.self)
                    .asObservable()
            }
            .share()
        
        fetchSprintReportAction.bind(to: outputs.activeScrum).disposed(by: bag)
        
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
            .share()
        
        let fetchFullIssuesActions = Observable
            .merge(
                fetchIssuesAction, fetchIssuesAction
                    .map {
                        $0.compactMap { Int($0.id) }
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
            ).share()
        
        let fetchEngineers = fetchFullIssuesActions
            .map {
                Array(Set($0.map { $0.assignee })).sorted()
            }
            .flatMap {
                Observable
                    .zip($0.map {
                        JiraAPIService
                            .provider
                            .rx
                            .request(.fetchEngineer(name: $0))
                            .asObservable()
                            .mapModel(Engineer.self)
                            .asObservable()
                    })
            }
            .share()
        
        Observable
            .zip(fetchFullIssuesActions, fetchEngineers)
            .flatMap { t -> Observable<[Issue]> in
                var issues = [Issue]()
                for i in 0..<t.0.count {
                    var issue = issues[i]
                    issue.engineer = t.1.filter { $0.name == issue.assignee }.first
                    issues.append(issue)
                }
                
                return Observable.from(optional: issues)
            }
            .bind(to: outputs.activeIssues)
            .disposed(by: bag)
        
        
        
    }
}
