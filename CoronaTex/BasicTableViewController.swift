//
//  BasicTableViewController.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/12/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit

class BasicTableViewController: UITableViewController {

    var rows: [[String]] = []
    let cellType = "basicCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func toArray(_ dictionary: [String: Int]) -> [[String]] {
        var table = [[String]]()
        
        for (key, value) in dictionary {
            table.append([key, String(value)])
        }
        
        return table
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellType)

        if cell == nil {
            cell = UITableViewCell(style: .value1, reuseIdentifier: cellType)
        }
        let row = rows[indexPath.row]
        cell!.textLabel?.text = row[0]
        cell!.detailTextLabel?.text = row[1]

        return cell!
    }
}
