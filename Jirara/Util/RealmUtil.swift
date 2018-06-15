//
//  RealmUtil.swift
//  Jirara
//
//  Created by kingcos on 2018/6/15.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Alamofire
import Foundation
import RealmSwift

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
                                    
                                    // 完成检索
//                                    completion()
                                    
                                    // 存储 Realm
                                    let realm = try! Realm()
//                                    let folderPath = realm.configuration.fileURL!.deletingLastPathComponent().path
                                    
                                    let engineersRealm = engineers.map { engineer -> EngineerRealm in
                                        let eng = EngineerRealm()
                                        eng.name = engineer.name
                                        eng.emailAddress = engineer.emailAddress
                                        eng.avatarURL = engineer.avatarURL
                                        eng.displayName = engineer.displayName
                                        
                                        let issues = (sprintReport.completedIssues + sprintReport.incompletedIssues).map { issue -> IssueRealm? in
                                            if issue.assignee == eng.name {
                                                let iss = IssueRealm()
                                                iss.id = issue.id
                                                iss.summary = issue.summary
                                                iss.priorityName = issue.priorityName
                                                iss.assignee = issue.assignee
                                                iss.statusName = issue.statusName
                                                
                                                return iss
                                            } else {
                                                return nil
                                            }
                                        }
                                        
                                        _ = issues.map { issue in
                                            if let iss = issue {
                                                eng.issues.append(iss)
                                            }
                                        }
                                        
                                        return eng
                                    }
                                    
                                    try! realm.write {
                                        realm.add(engineersRealm, update: true)
                                    }
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
    
    class func read() {
        
    }
    
    
}
