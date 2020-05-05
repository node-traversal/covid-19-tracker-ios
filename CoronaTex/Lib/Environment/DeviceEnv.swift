//
//  DeviceEnv.swift
//  CoronaTex
//
//  Created by Allen Parslow on 4/12/20.
//

import UIKit
import os.log

enum DeviceEnv {
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
