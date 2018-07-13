//
//  IssueViewModel.swift
//  Jirara
//
//  Created by kingcos on 2018/7/13.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import Alamofire

class IssueViewModel {
    
}

extension IssueViewModel {
    static let headers = ["Authorization" : UserDefaults.get(by: .accountAuth)]
    
    class func fetchIssueComments(_ id: String,
                                  _ completion: @escaping ([IssueComment]) -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.issue.rawValue
        
        Alamofire.request(url + id, headers: headers).responseData { response in
            switch response.result {
            case .success(let data):
                guard let issue = try? Issue(JSONData: data) else { return }
                
                completion(issue.comments)
            case .failure(let error):
                print((error as NSError).description)
            }
        }
    }
    
//    class func fetchTransitions(_ completion: @escaping ([IssueComment]) -> Void) {
//
//    }
    
    class func updateProgress(_ issueID: String,
                              _ comments: [IssueComment],
                              _ progress: String,
                              _ completion: @escaping () -> Void) {
        let progressComments = comments.filter { $0.body.hasPrefix(Constants.JiraIssueProgressPrefix) }
        
        let parameters: Parameters = [
            "author": [ "name": UserDefaults.get(by: .accountUsername) ],
            "body": Constants.JiraIssueProgressPrefix + progress
        ]
        
        if let progressComment = progressComments.first {
            // 已存在 -> 更新
            let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.issue.rawValue + issueID + JiraAPI.updateComment.rawValue + progressComment.id

            Alamofire.request(url, method: .put, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseData { response in
                switch response.result {
                case .success(let data):
                    guard let comment = try? IssueComment(JSONData: data) else { return }
                    
                    IssueCommentRealm.add(comment.toRealmObject())
                case .failure(let error):
                    print((error as NSError).description)
                }
            }
        } else {
            // 未存在 -> 新增
            let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.issue.rawValue + issueID + JiraAPI.updateComment.rawValue
            
            Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseData { response in
                switch response.result {
                case .success:
                    MainViewModel.fetchIssue(issueID) { _ in }
                case .failure(let error):
                    print((error as NSError).description)
                }
            }
        }
        // Workflow Status Update
        let transitionID: String
        switch progress {
        case Constants.JiraIssueProgressTodo:
            transitionID = Constants.JiraTransitionIDs[0]
        case Constants.JiraIssueProgressDone:
            transitionID = Constants.JiraTransitionIDs[2]
        default:
            transitionID = Constants.JiraTransitionIDs[1]
        }
        
        updateTransition(issueID, transitionID) { }
    }
    
    class func updateTransition(_ issueID: String,
                                _ transitionID: String,
                                _ completion: @escaping () -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.issue.rawValue + issueID + JiraAPI.updateTransition.rawValue
        let parameters: Parameters = [
            "transition": [ "id": transitionID ]
        ]
        Alamofire.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers)
                 .responseData { response in
                    switch response.result {
                    case .success:
                        completion()
                    case .failure(let error):
                        print((error as NSError).description)
                    }
        }
    }
}
