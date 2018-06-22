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
    class func fetch(_ rapidViewName: String = "Mobike iOS Scrum") {
        fetchRapidView(rapidViewName) { rapidViewID in
            fetchSprintQuery(rapidViewID) { sprintID in
                fetchSprintReport(rapidViewID, sprintID) { sprintReport in
                    fetchEngineers(sprintReport) {
                        // Notify
                        NotificationCenter.default.post(name: .UpdatedRemoteData, object: nil)
                    }
                }
            }
        }
    }
    
    class func fetchRapidView(_ name: String, completion: @escaping (Int) -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .jiraDomain) + JiraAPI.rapidView.rawValue
        let headers = ["Authorization" : UserDefaults.get(by: .userAuth)]
        
        Alamofire.request(url, headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    guard let rapidViews = try? RapidViews(JSONData: data) else {
                        fatalError("\(url) may be broken.")
                    }
                    
                    // print(rapidViews)
                    
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
    
    class func fetchSprintQuery(_ rapidViewID: Int, completion: @escaping (Int) -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .jiraDomain) + JiraAPI.sprintQuery.rawValue + "\(rapidViewID)"
        let headers = ["Authorization" : UserDefaults.get(by: .userAuth)]
        
        Alamofire.request(url, headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    guard let sprintQuery = try? SprintQuery(JSONData: data) else {
                        fatalError("\(url) may be broken.")
                    }
                    
                    // print(sprintQuery)
                    
                    for sprint in sprintQuery.sprints {
                        if sprint.state == "ACTIVE" {
                            completion(sprint.id)
                        }
                    }
                    
                case .failure(let error):
                    print((error as NSError).description)
                }
        }
    }
    
    class func fetchSprintReport(_ rapidViewID: Int, _ sprintID: Int, _ completion: @escaping (SprintReport) -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .jiraDomain) + JiraAPI.sprintReport.rawValue
        let parameters = ["rapidViewId" : rapidViewID,
                          "sprintId" : sprintID]
        let headers = ["Authorization" : UserDefaults.get(by: .userAuth)]
        
        Alamofire.request(url, parameters: parameters, headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    guard var sprintReport = try? SprintReport(JSONData: data) else {
                        fatalError("\(url) may be broken.")
                    }
                    
                    func formatDate(_ origin: String) -> String {
                        // 15/06/18 dd/mm/yy
                        let chineseMonth = origin.split(separator: "/")[1]
                        let numberMonth = Constants.MonthNumberDict[String(chineseMonth)]
                        let substrings = origin.replacingOccurrences(of: chineseMonth, with: numberMonth ?? "").split(separator: " ")
                        
                        let formatter = DateFormatter()
                        formatter.dateFormat = "dd/mm/yy"
                        let date = formatter.date(from: String(substrings[0])) ?? Date()
                        
                        formatter.dateFormat = "mmdd"
                        return formatter.string(from: date)
                    }
                    
                    sprintReport.startDate = formatDate(sprintReport.startDate)
                    sprintReport.endDate = formatDate(sprintReport.endDate)
                    
                    // Sprint Report
                    SprintReportRealmDAO.add(sprintReport.toRealmObject())
                    
                    completion(sprintReport)
                    
                case .failure(let error):
                    print((error as NSError).description)
                }
        }
    }
    
    class func fetchEngineers(_ sprintReport: SprintReport, _ completion: @escaping () -> Void) {
        let engineerNames = Array(Set((sprintReport.completedIssues + sprintReport.incompletedIssues).map { $0.assignee }))
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .jiraDomain) + JiraAPI.user.rawValue
        let headers = ["Authorization" : UserDefaults.get(by: .userAuth)]
        let requests = engineerNames.map { Alamofire.request(url, parameters: ["username" : $0], headers: headers) }
        
        var engineers = [Engineer]()
        
        _ = requests.map {
            $0.responseData { response in
                switch response.result {
                case .success(let data):
                    guard var engineer = try? Engineer(JSONData: data) else {
                        return
                    }
                    
                    engineer.issues = (sprintReport.completedIssues + sprintReport.incompletedIssues).filter { $0.assignee == engineer.name }
                    
                    engineers.append(engineer)
                    
                    if engineers.count == engineerNames.count {
                        engineers.sort { $0.name < $1.name }
                        
                        EngineerRealmDAO.add(engineers.map { $0.toRealmObject() })
                        completion()
                    }
                case .failure(let error):
                    print((error as NSError).description)
                }
            }
        }
    }
}
