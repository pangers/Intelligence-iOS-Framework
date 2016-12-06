//
//  MockTimeTrackerStorage.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 13/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

@testable import IntelligenceSDK

class MockTimeTrackerStorage: TimeTrackerStorageProtocol {
    var duration: UInt64?
    
    func reset() {
        duration = nil
    }
    
    func update(_ seconds: UInt64) {
        duration = seconds
    }
    
    func seconds() -> UInt64? {
        return duration
    }
}
