//
//  FirstViewController.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/12/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit

class FirstViewController: BasicTableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
    }
    
    private func loadData() {
        super.rows += toArray(CountryData.current.countyPopulation)
        super.rows.sort {
            $0[0] < $1[0]
        }
    }
}

