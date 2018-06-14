//
//  DetailsViewController.swift
//  Jirara
//
//  Created by kingcos on 2018/6/14.
//  Copyright © 2018 kingcos. All rights reserved.
//

import Cocoa
import Charts

class DetailsViewController: NSViewController {
    
    @IBOutlet weak var summaryChartView: PieChartView!
    
    var viewModel = MainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        
        
        viewModel.fetchSprintReport {
            self.updateSummaryChart()
        }
    }
    
}

extension DetailsViewController {
    func updateSummaryChart () {
        let completeIssuesCount = viewModel.sprintReport?.completedIssues.count ?? 0
        let completeIssueStatus = viewModel.sprintReport?.completedIssues.first?.statusName
        let completedIssuesEntry = PieChartDataEntry(value: Double(completeIssuesCount),
                                                     label: completeIssueStatus)
        
        let incompleteIssuesCount = viewModel.sprintReport?.incompletedIssues.count ?? 0
        let incompleteIssueStatus = "未完成"
        let incompletedIssuesEntry = PieChartDataEntry(value: Double(incompleteIssuesCount),
                                                       label: incompleteIssueStatus)
        
        let dataSet = PieChartDataSet(values: [completedIssuesEntry, incompletedIssuesEntry],
                                      label: nil)
        
        dataSet.colors = ChartColorTemplates.joyful()
        
        summaryChartView.data = PieChartData(dataSet: dataSet)
        summaryChartView.chartDescription = nil
        summaryChartView.centerAttributedText = NSAttributedString(string: "iOS Scrum",
                                                                   attributes: [.foregroundColor : NSColor.highlightColor])
        summaryChartView.holeColor = .clear
        
    }
}
