//
//  TitleViewController.swift
//  Jirara
//
//  Created by kingcos on 2018/6/14.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa

class TitleViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func clickOnSendEmailButton(_ sender: NSButton) {
        MailUtil.send(["ajgahjsgf"], to: ["cc:i-maiming@mobike.com"])
    }
    
    @IBAction func clickOnRefreshData(_ sender: NSButton) {
        MainViewModel.fetch()
    }
}
