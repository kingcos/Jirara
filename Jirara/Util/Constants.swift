//
//  Constants.swift
//  Jirara
//
//  Created by kingcos on 2018/6/14.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation

struct Constants {
    static let RapidViewName = "Mobike iOS Scrum"
    
    enum NotificationInfoKey: String {
        case engineer
    }
    
    static let MonthNumberDict: [String : String] = [
        "一月" : "01",
        "二月" : "02",
        "三月" : "03",
        "四月" : "04",
        "五月" : "05",
        "六月" : "06",
        "七月" : "07",
        "八月" : "08",
        "九月" : "09",
        "十月" : "10",
        "十一月" : "11",
        "十二月" : "12"
    ]
    
    static let dateFormat = "yyyy.MM.dd"
    
    static let JiraIssueProgressPrefix = "[Jirara-Progress]"
    static let JiraIssueProgressTodo = "ToDo"
    static let JiraIssueProgressDone = "Done"
    static let JiraIssueProgresses = [
        JiraIssueProgressTodo,
        "10%",
        "20%",
        "30%",
        "40%",
        "50%",
        "60%",
        "70%",
        "80%",
        "90%",
        JiraIssueProgressDone
    ]
    static let JiraTransitionIDs = ["11", "21", "31"]
    
    static let JiraRefresherDurationStart: Int32 = 30
    static let JiraRefresherDurationMax: Int32 = 300
    static let JiraRefresherDurationIncrement: Int32 = 10
}
