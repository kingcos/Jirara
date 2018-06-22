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
    var currentEngineerName: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
        setupUI()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(selectedEngineer(_:)),
                                               name: .SelectedEngineer,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updatedRemoteData),
                                               name: .UpdatedRemoteData,
                                               object: nil)
    }
}

extension DetailsViewController {
    func updateSummaryChart() {
        let todoIssuesCount = viewModel.issues(currentEngineerName).filter { $0.statusName == "Start" }.count
        let doingIssuesCount = viewModel.issues(currentEngineerName).filter { $0.statusName != "Start" && $0.statusName != "完成" }.count
        let doneIssuesCount = viewModel.issues(currentEngineerName).filter { $0.statusName == "完成" }.count
        
        let todoIssuesEntry = PieChartDataEntry(value: Double(todoIssuesCount),
                                                label: "To Do")
        let doingIssuesEntry = PieChartDataEntry(value: Double(doingIssuesCount),
                                                label: "Doing")
        let doneIssuesEntry = PieChartDataEntry(value: Double(doneIssuesCount),
                                                label: "Done")
        
        let dataSet = PieChartDataSet(values: [todoIssuesEntry, doingIssuesEntry, doneIssuesEntry],
                                      label: nil)
        
        dataSet.colors = ChartColorTemplates.joyful()
        summaryChartView.data = PieChartData(dataSet: dataSet)
        summaryChartView.centerAttributedText = NSAttributedString(string: "Mobike iOS Scrum",
                                                                   attributes: [.foregroundColor : NSColor.highlightColor])
        summaryChartView.animate(xAxisDuration: 1.0, easingOption: .easeOutBack)
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
        guard let userInfo = notification.userInfo,
            let selectedIndex = userInfo[Constants.NotificationInfoKey.engineer] as? Int else { return }
        if selectedIndex >= 0 {
            currentEngineerName = viewModel.engineers[selectedIndex].name
        } else {
            currentEngineerName = nil
        }
        updatedRemoteData()
    }
}

extension DetailsViewController: NSCollectionViewDataSource {
    func numberOfSections(in collectionView: NSCollectionView) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: NSCollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        switch section {
        case 0:
            return viewModel.issues(currentEngineerName).filter { $0.statusName == "Start" }.count
        case 1:
            return viewModel.issues(currentEngineerName).filter { $0.statusName != "Start" && $0.statusName != "完成" }.count
        case 2:
            return viewModel.issues(currentEngineerName).filter { $0.statusName == "完成" }.count
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
            issueCollectionViewItem.issue = viewModel.issues(currentEngineerName).filter { $0.statusName == "Start" }[indexPath.item]
        case 1:
            issueCollectionViewItem.issue = viewModel.issues(currentEngineerName).filter { $0.statusName != "Start" && $0.statusName != "完成" }[indexPath.item]
        case 2:
            issueCollectionViewItem.issue = viewModel.issues(currentEngineerName).filter { $0.statusName == "完成" }[indexPath.item]
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
                    view.status = "To Do"
                case 1:
                    view.status = "Doing"
                case 2:
                    view.status = "Done"
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

extension DetailsViewController {
    @objc func updatedRemoteData() {
        updateSummaryChart()
        issuesCollectionView.reloadData()
    }
}
