//
//  MutableCollectionType.swift
//  PhoenixSDK
//
//  Created by Michael Lake on 01/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

internal extension CollectionType where Index == Int {
    
    func shuffle() -> [Generator.Element] {
        var copy = Array(self)
        copy.shuffle()
        return copy
    }
    
}

internal extension MutableCollectionType where Index == Int {
    mutating func shuffle() {
        if count < 2 {
            // Collection with 0 or 1 element(s) are already shuffled
            return
        }
        
        for index in 0..<count - 1 {
            let unsortedIndex = Int(arc4random_uniform(UInt32(count - index))) + index
            
            guard index != unsortedIndex else {
                continue
            }
            
            swap(&self[index], &self[unsortedIndex])
        }
    }
}