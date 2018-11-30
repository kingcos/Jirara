//
//  MainViewModel.swift
//  Jirara
//
//  Created by kingcos on 2018/6/14.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import Alamofire

enum JiraraError: Error {
    case notFound
}

class MainViewModel {
    class func fetchRapidViewID(_ name: String,
                                _ completion: @escaping (Int?) -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.rapidView.rawValue
        let headers = ["Authorization" : UserDefaults.get(by: .accountAuth)]
        
        Alamofire.request(url, headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    guard let rapidViews = try? RapidViews(JSONData: data) else {
                        completion(nil)
                        return
                    }
                    for view in rapidViews.views {
                        if view.name == name {
                            completion(view.id)
                        }
                    }
                case .failure:
                    completion(nil)
                }
        }
    }
    
    class func fetchLastestSprintID(_ rapidViewID: Int,
                                    _ isActive: Bool,
                                    _ completion: @escaping (Int?) -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.sprintQuery.rawValue + "\(rapidViewID)"
        let headers = ["Authorization" : UserDefaults.get(by: .accountAuth)]
        
        Alamofire.request(url, headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    guard let sprintQuery = try? SprintQuery(JSONData: data) else {
                        completion(nil)
                        return
                    }
                    
                    if isActive {
                        sprintQuery.sprints.forEach { sprint in
                            if sprint.state == "ACTIVE" {
                                completion(sprint.id)
                            }
                        }
                    } else {
                        let newSprints = sprintQuery.sprints.filter { $0.state != "ACTIVE" }.sorted { $0.id < $1.id }
                        if let lastSprint = newSprints.last {
                            completion(lastSprint.id)
                        }
                    }
                    
                case .failure:
                    completion(nil)
                }
        }
    }
    
    class func fetchSprintReport(_ rapidViewID: Int,
                                 _ sprintID: Int,
                                 _ completion: @escaping (SprintReport?) -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.sprintReport.rawValue
        let parameters = ["rapidViewId" : rapidViewID,
                          "sprintId" : sprintID]
        let headers = ["Authorization" : UserDefaults.get(by: .accountAuth)]
        
        Alamofire.request(url, parameters: parameters, headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    guard let sprintReport = try? SprintReport(JSONData: data) else {
                        completion(nil)
                        return
                    }
                    
                    completion(sprintReport)
                case .failure:
                    completion(nil)
                }
        }
    }
    
    class func fetchIssues(_ sprintReport: SprintReport,
                           _ completion: @escaping ([Issue]) -> Void) {
        let issueIDs = (sprintReport.completedIssues + sprintReport.incompletedIssues).map { $0.id }
        guard !issueIDs.isEmpty else {
            completion([])
            return
        }
        
        var issues = [Issue]()
        issueIDs.forEach { id in
            fetchIssue(id) { issue in
                guard let issue = issue else {
                    fatalError()
                }
                issues.append(issue)
                let parentIssues = issues.filter { ($0.parentSummary ?? "") == "" }
                if issueIDs.count == parentIssues.count {
                    completion(issues)
                }
            }
        }
    }
    
    class func fetchIssue(_ id: Int,
                          _ completion: @escaping (Issue?) -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.issue.rawValue
        let headers = ["Authorization" : UserDefaults.get(by: .accountAuth)]
        
        Alamofire.request(url + "\(id)", headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                guard var issue = try? Issue(JSONData: data) else {
                    completion(nil)
                    return
                }
                
                fetchTransitions(issue.id) { transitions in
                    issue.transitions = transitions
                    
                    let subtaskIDs = issue.subtasks.map { Int($0.id)! }
                    
                    if subtaskIDs.isEmpty {
                        // 无子任务的父任务
                        completion(issue)
                    } else {
                        // 有子任务的父任务
                        subtaskIDs.forEach { id in
                            fetchIssue(id) { subissue in
                                guard let subissue = subissue else { return }
                                issue.subissues.append(subissue)
                                
                                if subtaskIDs.count == issue.subissues.count {
                                    completion(issue)
                                }
                            }
                        }
                    }
                }
            case .failure:
                completion(nil)
            }
        }
    }
    
    class func fetchSubtask(_ id: String,
                            _ completion: @escaping (Issue?) -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.issue.rawValue
        let headers = ["Authorization" : UserDefaults.get(by: .accountAuth)]
        
        Alamofire.request(url + id, headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                guard var issue = try? Issue(JSONData: data) else {
                    completion(nil)
                    return
                }
                
                fetchTransitions(issue.id) { transitions in
                    issue.transitions = transitions
                    
                    completion(issue)
                }
            case .failure:
                completion(nil)
            }
        }
    }
    
    class func fetchEngineers(_ issues: [Issue],
                              _ completion: @escaping ([Engineer]) -> Void) {
        let engineerNames = Array(Set(issues.map { $0.assignee })).sorted()
        
        guard !engineerNames.isEmpty else {
            completion([])
            return
        }
        
        var engineers = [Engineer]()
        engineerNames.forEach { name in
            fetchEngineer(name) { engineer in
                if let engineer = engineer {
                    engineers.append(engineer)
                    
                    if engineers.count == engineerNames.count {
                        completion(engineers)
                    }
                }
            }
        }
    }
    
    class func fetchEngineer(_ name: String,
                             _ completion: @escaping (Engineer?) -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.user.rawValue
        let headers = ["Authorization" : UserDefaults.get(by: .accountAuth)]
        
        Alamofire.request(url, parameters: ["username" : name], headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                guard let engineer = try? Engineer(JSONData: data) else {
                    completion(nil)
                    return
                }
                
                completion(engineer)
            case .failure:
                completion(nil)
            }
        }
    }
    
    class func fetchTransitions(_ id: String,
                                _ completion: @escaping ([Transition]) -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.issue.rawValue + id + JiraAPI.transitions.rawValue
        let headers = ["Authorization" : UserDefaults.get(by: .accountAuth)]
        
        Alamofire.request(url, headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                guard let transitions = try? Transitions(JSONData: data) else {
                    completion([])
                    return
                }
                
                completion(transitions.transitions)
            case .failure:
                completion([])
            }
        }
    }
}


extension MainViewModel {
    class func fetchMyIssuesInActiveSprintReport(_ completion: @escaping ([Issue]) -> Void) {
        fetchRapidViewID(Constants.RapidViewName) { rapidViewID in
            fetchLastestSprintID(rapidViewID ?? -1, true) { sprintID in
                fetchSprintReport(rapidViewID ?? -1, sprintID ?? -1) { sprintReport in
                    guard let sprintReport = sprintReport else {
                        completion([])
                        return
                    }
                    
                    fetchIssues(sprintReport) { issues in
                        let myIssues = (issues + issues.map { $0.subissues }.flatMap { $0 }).filter { $0.assignee == UserDefaults.get(by: .accountUsername) }
                        completion(myIssues)
                    }
                }
            }
        }
    }
    
    class func fetch(_ rapidViewName: String,
                     _ isActive: Bool = true,
                     _ completion: @escaping (SprintReport?, [Issue]) -> Void) {
        fetchRapidViewID(rapidViewName) { rapidViewID in
            fetchLastestSprintID(rapidViewID ?? -1, isActive) { sprintID in
                fetchSprintReport(rapidViewID ?? -1, sprintID ?? -1) { sprintReport in
                    guard let sprintReport = sprintReport else {
                        completion(nil, [])
                        return
                    }
                    
                    fetchIssues(sprintReport) { issues in
                        fetchEngineers(issues) { engineers in
                            var issues = issues + issues.flatMap { $0.subissues }
                            for i in 0..<issues.count {
                                issues[i].engineer = engineers.filter { $0.name == issues[i].assignee }.first
                            }
                            completion(sprintReport, issues)
                        }
                    }
                }
            }
        }
    }
}

