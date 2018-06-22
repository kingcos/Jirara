//
//  TitleViewController.swift
//  Jirara
//
//  Created by kingcos on 2018/6/14.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa
import Charts

class TitleViewController: NSViewController {
    
    var viewModel = MainViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func clickOnSendEmailButton(_ sender: NSButton) {
        MailUtil.send(generateChart()?.screenshot())
    }
    
    @IBAction func clickOnRefreshData(_ sender: NSButton) {
        MainViewModel.fetch()
    }
}

// d
extension TitleViewController {
    func generateChart() -> NSView? {
        let frame = CGRect(x: 0.0, y: 0.0, width: 300.0, height: 300.0)
        let pieChartView = PieChartView(frame: frame)
        
        let todoIssuesCount = viewModel.issues(nil).filter { $0.statusName == "Start" }.count
        let doingIssuesCount = viewModel.issues(nil).filter { $0.statusName != "Start" && $0.statusName != "完成" }.count
        let doneIssuesCount = viewModel.issues(nil).filter { $0.statusName == "完成" }.count

        let todoIssuesEntry = PieChartDataEntry(value: Double(todoIssuesCount),
                                                label: "To Do")
        let doingIssuesEntry = PieChartDataEntry(value: Double(doingIssuesCount),
                                                 label: "Doing")
        let doneIssuesEntry = PieChartDataEntry(value: Double(doneIssuesCount),
                                                label: "Done")

        let dataSet = PieChartDataSet(values: [todoIssuesEntry, doingIssuesEntry, doneIssuesEntry],
                                      label: nil)

        dataSet.colors = ChartColorTemplates.joyful()
        
        pieChartView.holeColor = .clear
        pieChartView.chartDescription = nil
        pieChartView.data = PieChartData(dataSet: dataSet)
        
        return pieChartView
    }
}
