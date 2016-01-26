//
//  NSDateFormatterHelper.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 19/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// - Returns: Date formatter capable of parsing dates formatted like: '2015-07-08T08:04:48.403'
internal var RFC3339DateFormatter: NSDateFormatter {
    struct Static {
        static var instance : NSDateFormatter? = nil
        static var token : dispatch_once_t = 0
    }
    dispatch_once(&Static.token) {
        Static.instance = NSDateFormatter.RFC3339Formatter()
    }
    return Static.instance!
}

extension NSDateFormatter {
    
    class func RFC3339Formatter() -> NSDateFormatter {
        let dateFormatter = NSDateFormatter()
        dateFormatter.calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
        dateFormatter.timeZone = NSTimeZone(name: "UTC")
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'"
        return dateFormatter
    }
    
}