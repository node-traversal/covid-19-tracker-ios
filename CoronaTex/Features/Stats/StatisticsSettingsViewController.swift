//
//  StatisticsSettingsViewController.swift
//  CoronaTex
//
//  Created by Allen Parslow on 5/4/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class StatisticsSettingsViewController: LocationSettingsViewController<StatisticsSettings> {
    @IBOutlet private weak var groupBySelector: UISegmentedControl!
    @IBOutlet private weak var sortBySelector: UISegmentedControl!
    @IBOutlet private weak var selectStateButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
                 
        guard let settings = self.settings else { return }
        
        groupBySelector.selectedSegmentIndex = StatisticsSettings.groupBySelections.firstIndex(of: settings.groupBy) ?? 0
        sortBySelector.selectedSegmentIndex = StatisticsSettings.sortSelections.firstIndex(of: settings.sortBy) ?? 0
    }
    
    // MARK: - Overrides
    
    override func newSettings() -> StatisticsSettings? {
        return StatisticsSettings()
    }
    
    override func selectStateUIButton() -> UIButton? {
        return selectStateButton
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let settings = self.settings else { return }
        
        settings.groupBy = StatisticsSettings.groupBySelections[groupBySelector.selectedSegmentIndex]
        settings.sortBy = StatisticsSettings.sortSelections[sortBySelector.selectedSegmentIndex]
        
        print("Save settings")
    }
    
    // MARK: - Navigation
    
    @IBAction private func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
        
    @IBAction private func selectState(_ sender: Any) {
        super.pickState(sender)
    }
}
