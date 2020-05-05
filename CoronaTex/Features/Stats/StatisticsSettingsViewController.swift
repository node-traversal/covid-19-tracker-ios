//
//  StatisticsSettingsViewController.swift
//  CoronaTex
//
//  Created by Allen Parslow on 5/4/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class StatisticsSettingsViewController: UIViewController {
    @IBOutlet private weak var groupBySelector: UISegmentedControl!
    @IBOutlet private weak var sortBySelector: UISegmentedControl!
    @IBOutlet private weak var selectStateButton: UIButton!
    
    var settings = StatisticsSettings()
    let allStates: String = "All States"
    var states = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        states = [allStates]
        states.append(contentsOf: CountryData.current.states)
        setState(settings.selectedState)
        
        groupBySelector.selectedSegmentIndex = StatisticsSettings.groupBySelections.firstIndex(of: settings.groupBy) ?? 0
        sortBySelector.selectedSegmentIndex = StatisticsSettings.sortSelections.firstIndex(of: settings.sortBy) ?? 0
    }
    
    // MARK: - Navigation
    
    @IBAction private func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        settings.groupBy = StatisticsSettings.groupBySelections[groupBySelector.selectedSegmentIndex]
        settings.sortBy = StatisticsSettings.sortSelections[sortBySelector.selectedSegmentIndex]
        
        print("Save settings")
    }
    
    private func setState(_ state: String) {
        self.selectStateButton.setTitle(state.isEmpty || state == allStates ? "Select" : state, for: .normal)
        self.selectStateButton.sizeToFit()
    }
    
    @IBAction private func selectState(_ sender: Any) {
        var selection = 0
        if !self.settings.selectedState.isEmpty {
            selection = states.firstIndex(of: self.settings.selectedState ) ?? 0
        }
        
        let picker = ActionSheetStringPicker(
            title: "Select State",
            rows: self.states,
            initialSelection: selection,
            doneBlock: { _, _, value in
                if let state = value as? String {
                    self.settings.selectedState = state == self.allStates ? "" : state
                    self.setState(state)
                }
                return
            },
            cancel: { _ in
                self.settings.selectedState = ""
                self.setState("")
            },
            origin: sender
        )
        
        let cancelButton = UIButton()
        cancelButton.setTitle("Clear", for: .normal)
        cancelButton.setTitleColor(self.view.tintColor, for: .normal)
        cancelButton.setTitleColor(UIColor.systemRed, for: .highlighted)
        
        picker?.setCancelButton(UIBarButtonItem.init(customView: cancelButton))
        picker?.show()
    }
}
