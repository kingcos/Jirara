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
    class func updateTransition(_ issueID: String,
                                _ transitionID: String,
                                _ completion: @escaping () -> Void) {
        let url = JiraAPI.prefix.rawValue + UserDefaults.get(by: .accountJiraDomain) + JiraAPI.issue.rawValue + issueID + JiraAPI.transitions.rawValue
        let headers = ["Authorization" : UserDefaults.get(by: .accountAuth)]
        let parameters: Parameters = [
            "transition": [ "id": transitionID ]
        ]
        Alamofire.request(url,
                          method: .post,
                          parameters: parameters,
                          encoding: JSONEncoding.default,
                          headers: headers)
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
