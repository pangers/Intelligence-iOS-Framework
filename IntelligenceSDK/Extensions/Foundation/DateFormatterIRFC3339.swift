//
//  NSDateFormatterHelper.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 19/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// - Returns: Date formatter capable of parsing dates formatted like: '2015-07-08T08:04:48.403Z'
/// See https://www.ietf.org/rfc/rfc3339.txt
var RFC3339DateFormatter: DateFormatter {
    struct Static {
        static var instance: DateFormatter = DateFormatter.RFC3339Formatter()
    }
    return Static.instance
}

extension DateFormatter {

    class func RFC3339Formatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        return dateFormatter
    }

    class func standatrdFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .gregorian)
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
        return dateFormatter
    }
}
