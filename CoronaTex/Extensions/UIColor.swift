//
//  UIColor.swift
//  CoronaTex
//
//  Created by Allen Parslow on 5/5/20.
//  Copyright © 2020 node-traversal. All rights reserved.
//

import UIKit

extension UIColor {
    func interpolateRGBColorTo(_ end: UIColor, fraction: CGFloat) -> UIColor? {
        let fractional = min(max(0, fraction), 1)

        guard let comp1 = self.cgColor.components, let comp2 = end.cgColor.components else { return nil }

        let red: CGFloat = CGFloat(comp1[0] + (comp2[0] - comp1[0]) * fractional)
        let green: CGFloat = CGFloat(comp1[1] + (comp2[1] - comp1[1]) * fractional)
        let blue: CGFloat = CGFloat(comp1[2] + (comp2[2] - comp1[2]) * fractional)

        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
