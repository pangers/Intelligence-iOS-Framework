//
//  String.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 29/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation


internal extension String {
    
    subscript (index: Int) -> Character {
        return self[self.startIndex.advancedBy(index)]
    }
    
    /// - Returns: true if self contains the passed string.
    func contains(string:String) -> Bool {
        return rangeOfString(string) != nil
    }
    
    /// - Returns: true if string passed contains self string.
    func isContained(string:String) -> Bool {
        return string.contains(self)
    }
    
}