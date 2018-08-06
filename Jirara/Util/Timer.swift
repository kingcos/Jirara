//
//  Timer.swift
//  Jirara
//
//  Created by kingcos on 2018/8/6.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation

typealias ActionBlock = () -> ()

class Timer {
    static let shared = Timer()
    
    lazy var timerContainer = [String: DispatchSourceTimer]()
    
    enum Name: String {
        case jiraRefresher
    }
    
    /// GCD定时器
    ///
    /// - Parameters:
    ///   - name: 定时器名字
    ///   - timeInterval: 时间间隔
    ///   - queue: 队列
    ///   - repeats: 是否重复
    ///   - action: 执行任务的闭包
    func scheduled(_ name: Name, _ timeInterval: Double, _ queue: DispatchQueue, _ repeats: Bool, _ action: @escaping ActionBlock) {
        var timer = timerContainer[name.rawValue]
        
        if timer == nil {
            timer = DispatchSource.makeTimerSource(flags: [], queue: queue)
            timer?.resume()
            timerContainer[name.rawValue] = timer
        }
        //精度0.1秒
        timer?.schedule(deadline: .now(), repeating: timeInterval, leeway: DispatchTimeInterval.milliseconds(100))
        timer?.setEventHandler(handler: { [weak self] in
            action()
            if repeats == false {
                self?.cancle(name)
            }
        })
    }
    
    /// 取消定时器
    ///
    /// - Parameter name: 定时器名字
    func cancle(_ name: Name) {
        if let timer = timerContainer[name.rawValue] {
            timerContainer.removeValue(forKey: name.rawValue)
            timer.cancel()
        }
    }
}
