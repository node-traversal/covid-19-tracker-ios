//
//  SecondViewController.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/12/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//
//  Derived from:
//  Env.swift
//  SwiftCharts
//
//  Created by ischuetz on 07/05/15.
//  Copyright (c) 2015 ivanschuetz. All rights reserved.
//

import UIKit
import os.log

class Env {
    
    static var iPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static var orientation: UIInterfaceOrientation {
        guard let ori = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else {
            os_log("Could not aquire orientation", log: OSLog.default, type: .error)
            return UIInterfaceOrientation.portrait
        }
        
        return ori
    }
}
