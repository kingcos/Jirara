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
    @IBOutlet weak var issuesCollectionView: NSCollectionView!
    
    var viewModel = MainViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupUI()
        
        NotificationCenter.default.addObserver(self, selector: #selector(selectedEngineer(_:)), name: .SelectedEngineer, object: nil)
        
        viewModel.fetchSprintReport {
            self.updateSummaryChart()
            self.issuesCollectionView.reloadData()
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
        summaryChartView.centerAttributedText = NSAttributedString(string: "iOS Scrum",
                                                                   attributes: [.foregroundColor : NSColor.highlightColor])
    }
}

extension DetailsViewController {
    func setupUI() {
        view.wantsLayer = true
        
        setupIssuesCollectionView()
        setupSummaryChartView()
    }
    
    func setupIssuesCollectionView() {
        let flowLayout = NSCollectionViewFlowLayout()
        flowLayout.itemSize = NSSize(width: issuesCollectionView.frame.width, height: 30.0)
        flowLayout.minimumInteritemSpacing = 0.0
        flowLayout.minimumLineSpacing = 0.0
        
        issuesCollectionView.collectionViewLayout = flowLayout
        issuesCollectionView.dataSource = self
        issuesCollectionView.delegate = self
    }
    
    func setupSummaryChartView() {
        summaryChartView.holeColor = .clear
        summaryChartView.chartDescription = nil
    }
    
    @objc func selectedEngineer(_ notification: NSNotification) {
        viewModel.fetchEngineers {
            self.viewModel.fetchSprintReport {
                guard let userInfo = notification.userInfo,
                    let selectedIndex = userInfo[Constants.NotificationInfoKey.engineer] as? Int else { return }
                if selectedIndex >= 0 {
                    let engineerName = self.viewModel.engineers[selectedIndex].name
                    let engineerCompletedIssues = (self.viewModel.sprintReport?.completedIssues ?? []).filter {
                        $0.assignee == engineerName
                    }
                    
                    let engineerIncompletedIssus = (self.viewModel.sprintReport?.incompletedIssues ?? []).filter {
                        $0.assignee == engineerName
                    }
                    
                    self.viewModel.sprintReport?.completedIssues = engineerCompletedIssues
                    self.viewModel.sprintReport?.incompletedIssues = engineerIncompletedIssus
                }
                
                self.updateSummaryChart()
                self.issuesCollectionView.reloadData()
            }
        }
    }
}

extension DetailsViewController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return (viewModel.sprintReport?.completedIssues ?? []).count
        case 1:
            return (viewModel.sprintReport?.incompletedIssues ?? []).count
        default:
            return 0
        }
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        let item = collectionView.makeItem(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "IssueCollectionViewItem"), for: indexPath)
        guard let issueCollectionViewItem = item as? IssueCollectionViewItem else { return item }
        
        switch indexPath.section {
        case 0:
            issueCollectionViewItem.issue = (viewModel.sprintReport?.completedIssues ?? [])[indexPath.item]
        case 1:
            issueCollectionViewItem.issue = (viewModel.sprintReport?.incompletedIssues ?? [])[indexPath.item]
        default:
            break
        }
        
        return issueCollectionViewItem
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        viewForSupplementaryElementOfKind kind: NSCollectionView.SupplementaryElementKind,
                        at indexPath: IndexPath) -> NSView {
        if kind == .sectionHeader {
            if let view = collectionView.makeSupplementaryView(ofKind: kind,
                                                            withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "IssuesStatusHeaderView"),
                                                            for: indexPath) as? IssuesStatusHeaderView {
                switch indexPath.section {
                case 0:
                    view.status = "已完成"
                case 1:
                    view.status = "进行中"
                default:
                    break
                }
                
                return view
            }
        }
        
        return NSView()
    }
}

extension DetailsViewController: NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> NSSize {
        return NSSize(width: collectionView.frame.width, height: 40.0)
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> NSSize {
        return NSSize.zero
    }
}
