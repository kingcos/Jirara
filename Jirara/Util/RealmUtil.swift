//
//  RealmUtil.swift
//  Jirara
//
//  Created by kingcos on 2018/6/15.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Alamofire
import Foundation

class RealmUtil {
    
    class func saveEngineers(_ completion: @escaping () -> Void) {
        var engineers = [Engineer]()
        
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .jiraDomain) + JiraAPI.sprintReport.rawValue
        let parameters = ["rapidViewId" : 80, "sprintId" : 1210]
        let headers = ["Authorization" : UserDefaults.get(by: .userAuth)]
        // https://jira.mobike.com/rest/api/2/user?username=
        Alamofire.request(url, parameters: parameters,headers: headers)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    guard let sprintReport = try? SprintReport(JSONData: data) else {
                        fatalError("\(url) may be broken.")
                    }
                    
                    // 得到 Issue 的 assignee（去重），即 Engineer 的 name
                    let engineerUsernames = Array(Set((sprintReport.completedIssues + sprintReport.incompletedIssues).map { $0.assignee }))
                    
                    // 如果数量相同，即完成，回调
                    if engineerUsernames.count == engineers.count {
                        completion()
                        return
                    }
                    
                    // 分别请求
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
                                
                                engineers.append(engineer)
                                
                                if engineers.count == engineerUsernames.count {
                                    engineers.sort { $0.name < $1.name }
                                    
                                    let engineersRealm = engineers.map { engineer -> EngineerRealm in
                                        var engineer = engineer
                                        let allIssues = (sprintReport.completedIssues + sprintReport.incompletedIssues).filter { issue in
                                            issue.assignee == engineer.name
                                        }
                                        
                                        engineer.issues = allIssues
                                        return engineer.toRealmObject()
                                    }
                                    EngineerRealmDAO.add(engineersRealm)
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
    
//    class func search(_ object: Object) {
//
//    }
    
    
}
