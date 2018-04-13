//
//  String.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 29/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

extension String {

    subscript(i: Int) -> Character {
//        return self[startIndex.advancedBy(index)]
        return self[index(startIndex, offsetBy: i)]
    }

    /// - Returns: true if self contains the passed string.
    func contains(string: String) -> Bool {
        return range(of: string) != nil
    }

    /// - Returns: true if string passed contains self string.
    func isContained(string: String) -> Bool {
        return string.contains(self)
    }

}
