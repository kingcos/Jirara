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
//    class func fetch(_ rapidViewName: String = "Mobike iOS Scrum",
//                     _ completion: @escaping (SprintReport, [EngineerRealm]) -> Void) {
//        fetchRapidView(rapidViewName) { rapidViewID in
//            fetchSprintQuery(rapidViewID) { sprintID in
//                fetchSprintReport(rapidViewID, sprintID) { sprintReport in
//                    fetchEngineers(sprintReport) { engineersRealm in
//                        completion(sprintReport, engineersRealm)
//                    }
//                }
//            }
//        }
//    }
    
    class func fetch(_ rapidViewName: String = "Mobike iOS Scrum",
                     _ completion: @escaping (SprintReport, [EngineerRealm]) -> Void) {
        fetchRapidView(rapidViewName) { rapidViewID in
            fetchSprintQuery(rapidViewID) { sprintID in
                fetchSprintReport(rapidViewID, sprintID) { sprintReport in
                    fetchIssues(sprintReport) { _ in
                        fetchEngineers(sprintReport) { engineersRealm in
                            completion(sprintReport, engineersRealm)
                        }
                    }
                }
            }
        }
    }
    
    class func fetchLast(_ rapidViewName: String = "Mobike iOS Scrum",
                         _ completion: @escaping (SprintReport, [EngineerRealm]) -> Void) {
        fetchRapidView(rapidViewName) { rapidViewID in
            fetchSprintQuery(rapidViewID, false) { sprintID in
                fetchSprintReport(rapidViewID, sprintID) { sprintReport in
                    fetchEngineers(sprintReport) { engineersRealm in
                        completion(sprintReport, engineersRealm)
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
                        // "Mobike iOS Scrum"
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
                                _ isLatest: Bool = true,
                                _ completion: @escaping (Int) -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.sprintQuery.rawValue + "\(rapidViewID)"
        
        Alamofire.request(url, headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    guard let sprintQuery = try? SprintQuery(JSONData: data) else {
                        fatalError("\(url) may be broken.")
                    }
                    
                    // print(sprintQuery)
                    
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
                                 _ completion: @escaping (SprintReport) -> Void) {
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
                    
                    completion(sprintReport)
                case .failure(let error):
                    print((error as NSError).description)
                }
        }
    }
    
    class func fetchIssues(_ sprintReport: SprintReport,
                           _ completion: @escaping ([IssueRealm]) -> Void) {
        let issues = sprintReport.completedIssues + sprintReport.incompletedIssues
        
        var issueRealms = [IssueRealm]()
        for issue in issues {
            fetchIssue(String(issue.id)) { issueRealm in
                issueRealms.append(issueRealm)
            }
        }
        completion(issueRealms)
    }
    
    class func fetchEngineers(_ sprintReport: SprintReport,
                              _ completion: @escaping ([EngineerRealm]) -> Void) {
        let engineerNames = (sprintReport.completedIssues + sprintReport.incompletedIssues).map { $0.assignee }
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.user.rawValue
        let requests = engineerNames.map { Alamofire.request(url, parameters: ["username" : $0], headers: headers) }
        
        var engineerRealms = [EngineerRealm]()
        for request in requests {
            request.responseData { response in
                switch response.result {
                case .success(let data):
                    guard let engineer = try? Engineer(JSONData: data) else {  return }
                    
                    EngineerRealmDAO.add(engineer.toRealmObject())
                    engineerRealms.append(engineer.toRealmObject())
                case .failure(let error):
                    print((error as NSError).description)
                }
            }
        }
        
        completion(engineerRealms)
    }
    
    class func fetchIssue(_ id: String,
                          _ completion: @escaping (IssueRealm) -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.issue.rawValue
        
        Alamofire.request(url + id, headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                guard let issue = try? Issue(JSONData: data) else { return }
                // Saved Issue
                IssueRealm.add(issue.toRealmObject())
                
                completion(issue.toRealmObject())
            case .failure(let error):
                print((error as NSError).description)
            }
        }
    }
}
