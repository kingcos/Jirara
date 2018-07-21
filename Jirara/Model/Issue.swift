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
    var priority: String
    var assignee: String
    var status: String
    var parentSummary: String?
    var subtasks: [IssueSubtask]?
    var comments: [IssueComment]
    
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
    }
}

struct IssueSubtask: Mappable {
    var id: String
    
    init(map: Mapper) throws {
        id = try map.from("id")
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

extension Issue: Realmable {
    func toRealmObject() -> IssueRealm {
        let object = IssueRealm()
        
        object.id = id
        object.key = key
        object.type = summary.contains("】") ? String(summary.split(separator: "】")[0] + "】") : "-"
        object.title = summary.replacingOccurrences(of: object.type, with: "")
        object.priority = priority
        object.assignee = assignee
        object.status = status
        
        object.parentSummary = ""
        if let parentSummary = parentSummary {
            if parentSummary.contains("】") {
                object.parentSummary = String(parentSummary.split(separator: "】")[1])
            }
        }
        // 取备注中 1. 自己的备注 2. 有进度前缀的备注
//        object.progress = comments.filter { $0.authorName == assignee && $0.body.hasPrefix(Constants.JiraIssueProgressPrefix) }.first?.body ?? ""
        object.comments.append(objectsIn: comments.map { $0.toRealmObject() })
        
        return object
    }
}

extension IssueComment: Realmable {
    func toRealmObject() -> IssueCommentRealm {
        let object = IssueCommentRealm()
        
        object.id = id
        object.author = authorName
        object.content = body
        
        return object
    }
}
