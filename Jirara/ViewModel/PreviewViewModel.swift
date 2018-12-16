//
//  PreviewViewModel.swift
//  Jirara
//
//  Created by kingcos on 2018/12/16.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Foundation

import RxCocoa
import RxSwift

struct PreviewViewModel {
    struct Input {
        let markdownTextDidChange = PublishSubject<Void>()
        let previewWindowDidShow = PublishSubject<Void>()
    }
    
    struct Output {
        let updateMardownView = PublishSubject<Void>()
        let mailContent = PublishSubject<String>()
    }
    
    let inputs = Input()
    let outputs = Output()
    
    let bag = DisposeBag()
    
    init() {
        binding()
    }
    
    func binding() {
        inputs.markdownTextDidChange.bind(to: outputs.updateMardownView).disposed(by: bag)
        
//        inputs.previewWindowDidShow.asObservable()
    }
}
