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
    var engneers: [Engineer] = []
    var sprintReport: SprintReport?
    
    func rapidView() {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .jiraDomain) + JiraAPI.rapidView.rawValue
        let headers = ["Authorization" : UserDefaults.get(by: .userAuth)]
        
        Alamofire.request(url, headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    guard let rapidViews = try? RapidViews(JSONData: data) else {
                            fatalError("\(url) may be broken.")
                    }
                    print(rapidViews)
                    
                case .failure(let error):
                    print((error as NSError).description)
                }
        }
    }
    
    func sprintQuery() {
        let id = 80
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .jiraDomain) + JiraAPI.sprintQuery.rawValue + "\(id)"
        let headers = ["Authorization" : UserDefaults.get(by: .userAuth)]
        
        Alamofire.request(url, headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    guard let sprintQuery = try? SprintQuery(JSONData: data) else {
                        fatalError("\(url) may be broken.")
                    }
                    print(sprintQuery)
                    
                case .failure(let error):
                    print((error as NSError).description)
                }
        }
    }
    
    func fetchSprintReport(_ completion: @escaping () -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .jiraDomain) + JiraAPI.sprintReport.rawValue
        let parameters = ["rapidViewId" : 80,
                          "sprintId" : 1210]
        let headers = ["Authorization" : UserDefaults.get(by: .userAuth)]
        
        Alamofire.request(url, parameters: parameters,headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    guard let sprintReport = try? SprintReport(JSONData: data) else {
                        fatalError("\(url) may be broken.")
                    }
                    self.sprintReport = sprintReport
                    completion()
                case .failure(let error):
                    print((error as NSError).description)
                }
        }
    }
    
    func fetchEngineers(_ completion: @escaping () -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .jiraDomain) + JiraAPI.sprintReport.rawValue
        let parameters = ["rapidViewId" : 80,
                          "sprintId" : 1210]
        let headers = ["Authorization" : UserDefaults.get(by: .userAuth)]
        // https://jira.mobike.com/rest/api/2/user?username=
        Alamofire.request(url, parameters: parameters,headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    guard let sprintReport = try? SprintReport(JSONData: data) else {
                        fatalError("\(url) may be broken.")
                    }
                    let engineerUsernames = Array(Set((sprintReport.completedIssues + sprintReport.incompletedIssues).map { $0.assignee }))
                    let requests = engineerUsernames.map {
                        Alamofire.request("https://jira.mobike.com/rest/api/2/user?username=\($0)", headers: headers)
                    }
                    
                    _ = requests.map {
                        $0.responseData { response in
                            switch response.result {
                            case .success(let data):
                                guard let engineer = try? Engineer(JSONData: data) else {
                                    return
                                }
                                
                                self.engneers.append(engineer)
                                
                                if self.engneers.count == engineerUsernames.count {
                                    self.engneers.sort { $0.name < $1.name }
                                    completion()
                                }
                            case .failure(let error):
                                print((error as NSError).description)
                            }
                        }
                    }
                case .failure(let error):
                    print((error as NSError).description)
                }
        }
    }
}
