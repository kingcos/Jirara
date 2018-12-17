//
//  Issue.swift
//  Jirara
//
//  Created by kingcos on 2018/7/11.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation
import Mappable

/**
 API: /rest/api/latest/issue/56848
 **/
struct Issue: Mappable {
    var id: String
    var key: String
    var summary: String
    var priority: String?
    var assignee: String
    var status: String
    var parentSummary: String?
    var subtasks: [IssueSubtask]
    var comments: [IssueComment]
    var transitions: [Transition] = []
    var subissues: [Issue] = []
    var engineer: Engineer?
    var type: String
    
    init(map: Mapper) throws {
        id = try map.from("id")
        key = try map.from("key")
        summary = try map.from("fields.summary")
        priority = try map.from("fields.priority.name")
        assignee = try map.from("fields.assignee.name")
        status = try map.from("fields.status.name")
        parentSummary = try map.from("fields.parent.fields.summary")
        subtasks = try map.from("fields.subtasks")
        comments = try map.from("fields.comment.comments")
        
        type = summary.matchedByRegex(UserDefaults.get(by: .issueTypeRegex)) ?? ""
        summary = summary.replacingOccurrences(of: type, with: "")
    }
}

extension Issue: Comparable {
    static func < (lhs: Issue, rhs: Issue) -> Bool {
        return lhs.id < rhs.id
    }
    
    static func == (lhs: Issue, rhs: Issue) -> Bool {
        let result = lhs.id == rhs.id
                  && lhs.key == rhs.key
                  && lhs.summary == rhs.summary
                  && lhs.priority == rhs.priority
                  && lhs.assignee == rhs.assignee
                  && lhs.status == rhs.status
                  && lhs.parentSummary == rhs.parentSummary
                  && lhs.subtasks == rhs.subtasks
                  && lhs.comments == rhs.comments
                  && lhs.transitions == rhs.transitions
                  && lhs.subissues == rhs.subissues
                  && lhs.engineer == rhs.engineer
                  && lhs.type == rhs.type
        return result
    }
}

struct IssueSubtask: Mappable {
    var id: String

    init(map: Mapper) throws {
        id = try map.from("id")
    }
}

extension IssueSubtask: Comparable {
    static func < (lhs: IssueSubtask, rhs: IssueSubtask) -> Bool {
        return lhs.id < rhs.id
    }
    
    static func == (lhs: IssueSubtask, rhs: IssueSubtask) -> Bool {
        return lhs.id == rhs.id
    }
}


struct IssueComment: Mappable {
    var id: String
    var authorName: String
    var body: String
    
    init(map: Mapper) throws {
        id = try map.from("id")
        authorName = try map.from("author.name")
        body = try map.from("body")
    }
}

extension IssueComment: Comparable {
    static func < (lhs: IssueComment, rhs: IssueComment) -> Bool {
        return lhs.id < rhs.id
    }
    
    static func == (lhs: IssueComment, rhs: IssueComment) -> Bool {
        return lhs.id == rhs.id && lhs.authorName == rhs.authorName && lhs.body == rhs.body
    }
}
