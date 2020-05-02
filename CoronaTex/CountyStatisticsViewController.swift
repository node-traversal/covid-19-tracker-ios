//
//  CountyStatisticsViewController.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/12/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit

class CountyStatisticsViewController: BasicTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
  
        loadData()
    }

    private func loadData() {
        super.rows += toArray([:])
        super.rows.sort {
            $0[0] < $1[0]
        }
    }
}
