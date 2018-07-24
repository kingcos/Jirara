//
//  MainViewModel.swift
//  Jirara
//
//  Created by kingcos on 2018/6/14.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import Alamofire

class MainViewModel {
    static let headers = ["Authorization" : UserDefaults.get(by: .accountAuth)]
    
    var engineers: [EngineerRealm] {
        get {
            return EngineerRealmDAO.findAll()
        }
    }
    
    var sprintReport: SprintReportRealm {
        get {
            return SprintReportRealmDAO.findLatest() ?? SprintReportRealm()
        }
    }
    
    func issues(_ assignee: String?) -> [IssueRealm] {
        let issues: [IssueRealm] = sprintReport.issues.map { $0 }
        
        if let assignee = assignee {
            return issues.filter { $0.assignee == assignee }
        }
        
        return issues
    }
}

extension MainViewModel {
    class func fetch(_ rapidViewName: String,
                     _ isLatest: Bool = true,
                     _ completion: @escaping () -> Void) {
        fetchRapidView(rapidViewName) { rapidViewID in
            fetchSprintQuery(rapidViewID, isLatest) { sprintID in
                fetchSprintReport(rapidViewID, sprintID) { sprintReport in
                    fetchIssues(sprintReport) { issueRealms in
                        fetchEngineers(issueRealms) { _ in
                            completion()
                        }
                    }
                }
            }
        }
    }
    
    class func fetchRapidView(_ name: String,
                              _ completion: @escaping (Int) -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.rapidView.rawValue
        
        Alamofire.request(url, headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    guard let rapidViews = try? RapidViews(JSONData: data) else {
                        fatalError("\(url) may be broken.")
                    }
                    for view in rapidViews.views {
                        if view.name == name {
                            completion(view.id)
                        }
                    }
                case .failure(let error):
                    print((error as NSError).description)
                }
        }
    }
    
    class func fetchSprintQuery(_ rapidViewID: Int,
                                _ isLatest: Bool,
                                _ completion: @escaping (Int) -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.sprintQuery.rawValue + "\(rapidViewID)"
        
        Alamofire.request(url, headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    guard let sprintQuery = try? SprintQuery(JSONData: data) else {
                        fatalError("\(url) may be broken.")
                    }
                    if isLatest {
                        for sprint in sprintQuery.sprints {
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
                    
                case .failure(let error):
                    print((error as NSError).description)
                }
        }
    }
    
    class func fetchSprintReport(_ rapidViewID: Int,
                                 _ sprintID: Int,
                                 _ completion: @escaping (SprintReportRealm) -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.sprintReport.rawValue
        let parameters = ["rapidViewId" : rapidViewID,
                          "sprintId" : sprintID]
        
        Alamofire.request(url, parameters: parameters, headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    guard let sprintReport = try? SprintReport(JSONData: data) else {
                        fatalError("\(url) may be broken.")
                    }
                    // Saved Sprint Report
                    SprintReportRealmDAO.add(sprintReport.toRealmObject())
                    
                    completion(sprintReport.toRealmObject())
                case .failure(let error):
                    print((error as NSError).description)
                }
        }
    }
    
    class func fetchIssues(_ sprintReport: SprintReportRealm,
                           _ completion: @escaping ([IssueRealm]) -> Void) {
        guard !sprintReport.issues.isEmpty else {
            completion([])
            return
        }
        
        var issueRealms = [IssueRealm]()
        for issue in sprintReport.issues {
            fetchIssue(String(issue.id)) { issueRealm in
                issueRealms.append(issueRealm)
                let issues = issueRealms.filter { $0.parentSummary == "" }
                if sprintReport.issues.count == issues.count {
                    completion(issueRealms)
                }
            }
        }
    }
    
    class func fetchIssue(_ id: String,
                          _ completion: @escaping (IssueRealm) -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.issue.rawValue
        
        Alamofire.request(url + id, headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                guard let issue = try? Issue(JSONData: data) else { return }
                
                let issueRealm = issue.toRealmObject()
                let subtasks = issue.subtasks ?? []
                
                if !subtasks.isEmpty {
                    // 有子任务的父任务
                    for subtask in subtasks {
                        fetchSubtask(subtask.id) { subtaskRealm in
                            issueRealm.subtasks.append(subtaskRealm)

                            if issueRealm.subtasks.count == subtasks.count {
                                IssueRealmDAO.add(issueRealm)
                                completion(issueRealm)
                            }
                        }
                    }
                } else {
                    // 无子任务的父任务
                    IssueRealmDAO.add(issueRealm)
                    completion(issueRealm)
                }
            case .failure(let error):
                print((error as NSError).description)
            }
        }
    }
    
    class func fetchSubtask(_ id: String,
                            _ completion: @escaping (IssueRealm) -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.issue.rawValue
        
        Alamofire.request(url + id, headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                guard let issue = try? Issue(JSONData: data) else { return }
                completion(issue.toRealmObject())
            case .failure(let error):
                print((error as NSError).description)
            }
        }
    }
    
    class func fetchEngineers(_ issues: [IssueRealm],
                              _ completion: @escaping ([EngineerRealm]) -> Void) {
        let engineerNames = Array(Set(issues.map { $0.assignee })).sorted()
        
        guard !engineerNames.isEmpty else {
            completion([])
            return
        }
        
        var engineerRealms = [EngineerRealm]()
        for name in engineerNames {
            fetchEngineer(name) { engineer, _ in
                if let engineer = engineer {
                    engineerRealms.append(engineer)
                    
                    if engineerRealms.count == engineerNames.count {
                        completion(engineerRealms)
                    }
                }
            }
        }
    }
    
    class func fetchEngineer(_ name: String,
                             _ completion: @escaping (EngineerRealm?, String?) -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.user.rawValue
        Alamofire.request(url, parameters: ["username" : name], headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                guard let engineer = try? Engineer(JSONData: data) else {
                    completion(nil, "JSON 解析失败 - AD 用户名或密码不正确")
                    return
                }
                
                completion(engineer.toRealmObject(), nil)
            case .failure(let error):
                completion(nil, (error as NSError).description)
            }
        }
    }
}
