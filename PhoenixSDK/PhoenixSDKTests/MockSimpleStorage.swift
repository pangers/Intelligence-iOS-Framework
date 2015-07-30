//
//  MockSimpleStorage.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 30/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

@testable import PhoenixSDK

struct MockSimpleStorage: PhoenixSDK.SimpleStorage {
    
    private var storage:[String:AnyObject] = [:]
    
    subscript(index: String) -> AnyObject? {
        get {
            return storage[index]
        }
        set {
            storage[index] = newValue
        }
    }
    
}