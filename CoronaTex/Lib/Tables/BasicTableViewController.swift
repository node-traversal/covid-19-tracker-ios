//
//  BasicTableViewController.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/12/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit

struct TableRow<KEY: Comparable & LosslessStringConvertible>: Comparable {
    static func < (lhs: TableRow<KEY>, rhs: TableRow<KEY>) -> Bool {
        lhs.sortKey < rhs.sortKey
    }
    
    static func == (lhs: TableRow<KEY>, rhs: TableRow<KEY>) -> Bool {
        lhs.sortKey == rhs.sortKey
    }
    
    let label: String
    let detail: String
    let sortKey: KEY
}

class BasicTableViewController<KEY: Comparable & LosslessStringConvertible>: UITableViewController {
    var rows = [TableRow<KEY>]()
    let cellType = "basicCell"

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func toTable(_ dictionary: [String: KEY]) -> [TableRow<KEY>] {
        var table = [TableRow<KEY>]()
        
        for (key, value) in dictionary {
            table.append(TableRow<KEY>(label: key, detail: String(value), sortKey: value))
        }
        
        return table
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
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
        cell!.textLabel?.text = row.label
        cell!.detailTextLabel?.text = row.detail

        return cell!
    }
}
