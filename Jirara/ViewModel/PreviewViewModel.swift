//
//  PreviewViewModel.swift
//  Jirara
//
//  Created by kingcos on 2018/12/16.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation

import RxCocoa
import RxSwift

struct PreviewViewModel {
    struct Input {
        let markdownTextDidChange = PublishSubject<Void>()
        let previewWindowDidShow = PublishSubject<Void>()
    }
    
    struct Output {
        let updateMardownView = PublishSubject<Void>()
        let mailContent = PublishSubject<String>()
    }
    
    let inputs = Input()
    let outputs = Output()
    
    let bag = DisposeBag()
    
    let formatter = DateFormatter()
    
    init() {
        formatter.dateFormat = Constants.DateFormat
        
        binding()
    }
    
    func binding() {
        inputs.markdownTextDidChange.bind(to: outputs.updateMardownView).disposed(by: bag)
        
        let fetchRapidViewAction = inputs
            .previewWindowDidShow
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
                Observable.zip(
                    Observable.just($0),
                    JiraAPIService
                        .provider
                        .rx
                        .request(.fetchSprintID(rapidViewID: $0.id))
                        .asObservable()
                        .mapModel(SprintQuery.self)
                        .map { $0.sprints }
                )
            }
            .flatMap {
                Observable
                    .zip(Observable.just($0.0),
                         Observable.from(optional: $0.1.first { $0.state == "ACTIVE" }))
            }
            .flatMap {
                JiraAPIService
                    .provider
                    .rx
                    .request(.fetchSprintReport(rapidViewID: $0.0.id,
                                                sprintID: $0.1.id))
                    .asObservable()
                    .mapModel(SprintReport.self)
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
        
        let fetchEngineersAction = fetchIssuesAndSubissuesActions
            .map { Array(Set($0.map { $0.assignee })) }
            .flatMap {
                Observable.zip($0.map {
                    JiraAPIService
                        .provider
                        .rx
                        .request(.fetchEngineer(name: $0))
                        .asObservable()
                        .mapModel(Engineer.self)
                    })
            }
            .catchErrorJustReturn([])
            .share()
        
        let fetchIssueWithEngineersAction = Observable
            .zip(fetchIssuesAndSubissuesActions, fetchEngineersAction)
            .flatMap { t -> Observable<[Issue]> in
                var issues = t.0
                for i in 0..<t.0.count {
                    issues[i].engineer = t.1.first { $0.name == issues[i].assignee }
                }
                return Observable.from(optional: issues.sorted())
            }
            .catchErrorJustReturn([])
            .share()
        
        Observable
            .zip(fetchActiveSprintAction, fetchIssueWithEngineersAction)
            .flatMap { t -> Observable<String> in
                func generate(_ content: inout String,
                              _ issues: [Issue]) {
                    guard !issues.isEmpty else { return }
                    
                    for type in Array(Set(issues.map { $0.type })).sorted() {
                        if type != "" {
                            content.append(
"""

- \(type)

"""
                            )
                        }
                        
                        content.append(
"""

<table style="border-collapse:collapse">
<tr><td width=600>任务</td><td width=180>负责人</td><td width=80>状态</td></tr>

"""
)
                        let filteredIssues = issues
                            .filter { $0.type == type }
                            .sorted { $0.assignee < $1.assignee }
                        
                        for issue in filteredIssues {
                            content.append(
"""
<tr><td>\(issue.summary)</td><td>\(issue.engineer?.displayName ?? issue.assignee)</td><td>\(issue.status)</td></tr>

"""
                            )
                            
                            for subissue in issue.subissues {
                                content.append(
"""
<tr><td>┗─ \(subissue.summary)</td><td>\(subissue.engineer?.displayName ?? subissue.assignee)</td><td>\(subissue.status)</td></tr>

"""
                                )
                            }
                        }
                        content.append("</table><br>\n")
                    }
                    content.append("<br>\n")
                }
                var content =
"""
<style>
  td { border:1px solid #B0B0B0 }
</style>
                
<h2>\(UserDefaults.get(by: .mailSubject))</h2>
                
<h4>周期：\(t.0.startDate) ~ \(t.0.endDate) 统计日期：\(Date.today)</h4>


"""
                generate(&content, t.1)
                return Observable.just(content)
            }
            .bind(to: outputs.mailContent)
            .disposed(by: bag)
        
        // Last week
//        let fetchLatestInactiveSprintAction = fetchRapidViewAction
//            .flatMap {
//                JiraAPIService
//                    .provider
//                    .rx
//                    .request(.fetchSprintID(rapidViewID: $0.id))
//                    .asObservable()
//                    .mapModel(SprintQuery.self)
//                    .map { $0.sprints }
//            }
//            .flatMap {
//                Observable
//                    .from(optional: $0.sorted().last { $0.state != "ACTIVE" })
//            }
//            .share()
//
//        let fetchLastIssuesAction = Observable
//            .zip(fetchRapidViewAction, fetchLatestInactiveSprintAction)
//            .flatMap {
//                JiraAPIService
//                    .provider
//                    .rx
//                    .request(.fetchSprintReport(rapidViewID: $0.0.id,
//                                                sprintID: $0.1.id))
//                    .asObservable()
//                    .mapModel(SprintReport.self)
//                    .map { $0.completedIssues + $0.incompletedIssues }
//            }
//            .flatMap {
//                Observable
//                    .zip($0.map {
//                        JiraAPIService
//                            .provider
//                            .rx
//                            .request(.fetchIssue(id: $0.id))
//                            .asObservable()
//                            .mapModel(Issue.self)
//                    })
//            }
//            .catchErrorJustReturn([])
//            .share()
//
//        let fetchLastIssuesAndSubissuesActions = Observable
//            .merge(
//                fetchLastIssuesAction,
//                fetchLastIssuesAction
//                    .map {
//                        $0.flatMap {
//                            $0.subtasks.compactMap { Int($0.id) }
//                        }
//                    }
//                    .flatMap {
//                        Observable
//                            .zip($0.map {
//                                JiraAPIService
//                                    .provider
//                                    .rx
//                                    .request(.fetchIssue(id: $0))
//                                    .asObservable()
//                                    .mapModel(Issue.self)
//                            })
//                }
//            )
//            .map { $0.sorted() }
//            .catchErrorJustReturn([])
//            .share()
//
//        let fetchLastEngineersAction = fetchLastIssuesAndSubissuesActions
//            .map { Array(Set($0.map { $0.assignee })) }
//            .flatMap {
//                Observable.zip($0.map {
//                    JiraAPIService
//                        .provider
//                        .rx
//                        .request(.fetchEngineer(name: $0))
//                        .asObservable()
//                        .mapModel(Engineer.self)
//                })
//            }
//            .catchErrorJustReturn([])
//            .share()
//
//        let fetchLastIssueWithEngineersAction = Observable
//            .zip(fetchLastIssuesAndSubissuesActions, fetchLastEngineersAction)
//            .flatMap { t -> Observable<[Issue]> in
//                var issues = t.0
//                for i in 0..<t.0.count {
//                    issues[i].engineer = t.1.first { $0.name == issues[i].assignee }
//                }
//                return Observable.from(optional: issues.sorted())
//            }
//            .catchErrorJustReturn([])
//            .share()
//
    }
}
