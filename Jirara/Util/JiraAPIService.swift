//
//  JiraAPIService.swift
//  Jirara
//
//  Created by kingcos on 2018/12/8.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import RxSwift
import Moya

enum JiraAPIService {
    case fetchRapidViewID
    case fetchSprintID(rapidViewID: Int)
    case fetchSprintReport(rapidViewID: Int, sprintID: Int)
    case fetchIssue(id: Int)
    case fetchSubtask(id: Int)
    case fetchEngineer(name: String)
    case fetchTransitions(id: Int)
    case updateIssueTransition(issueID: Int, transitionID: Int)
    
    static let provider = MoyaProvider<JiraAPIService>()
    static let scheme = "https://"
}

extension JiraAPIService: TargetType {
    var baseURL: URL {
        return URL(string: UserDefaults.get(by: .accountJiraDomain))!
    }
    
    var path: String {
        switch self {
        case .fetchRapidViewID:
            return "/rest/greenhopper/1.0/rapidview"
        case .fetchSprintID(let rapidViewID):
            return "/rest/greenhopper/1.0/sprintquery/\(rapidViewID)"
        case .fetchSprintReport:
            return "/rest/greenhopper/1.0/rapid/charts/sprintreport"
        case .fetchIssue(let id), .fetchSubtask(let id):
            return "/rest/api/2/issue/\(id)"
        case .fetchEngineer:
            return "/rest/api/2/user"
        case .fetchTransitions(let id), .updateIssueTransition(let id, _):
            return "/rest/api/2/issue/\(id)/transitions"
        }
    }
    
    var headers: [String : String]? {
        return ["Authorization" : UserDefaults.get(by: .accountAuth)]
    }
    
    var method: Moya.Method {
        switch self {
        case .updateIssueTransition:
            return .post
        default:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .fetchSprintReport(let rapidViewID, let sprintID):
            return .requestParameters(parameters: ["rapidViewId" : rapidViewID,
                                                   "sprintId" : sprintID],
                                      encoding: URLEncoding.queryString)
        case .fetchEngineer(let name):
            return .requestParameters(parameters: ["username" : name],
                                      encoding: URLEncoding.queryString)
        case .updateIssueTransition(_, let transitionID):
            return .requestParameters(parameters: ["transition" : ["id" : transitionID]],
                                      encoding: JSONEncoding.default)
        default:
            return .requestPlain
        }
    }
    
    var sampleData: Data {
        return Data()
    }
}
