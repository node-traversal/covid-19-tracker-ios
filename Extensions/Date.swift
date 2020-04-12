//
//  Date.swift
//  Examples
//
//  Created by Allen Parslow on 4/13/20.
//  Copyright © 2020 ivanschuetz. All rights reserved.
//

import UIKit

extension Date: Strideable {
    static var daysDurationInSeconds: TimeInterval {
        return 60*60*24
    }
    
    public func days(to other: Date) -> TimeInterval {
        return (other.timeIntervalSinceReferenceDate - self.timeIntervalSinceReferenceDate) / Date.daysDurationInSeconds
    }

    
    public func distance(to other: Date) -> TimeInterval {
        return other.timeIntervalSinceReferenceDate - self.timeIntervalSinceReferenceDate
    }

    public func advanced(by n: TimeInterval) -> Date {
        return self + n
    }
}
