//
//  MockSimpleStorage.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 30/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

@testable import IntelligenceSDK

class MockSimpleStorage: IntelligenceOAuthStorage {
    
    fileprivate var storage: [String: AnyObject?] = [:]
    
    @objc subscript(index: String) -> AnyObject? {
        get {
            guard let obj = storage[index] else { return nil }
            return obj
        }
        set {
            storage[index] = newValue
        }
    }
    
}
