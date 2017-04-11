//
//  MockAnalyticsModule.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 06/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit

@testable import IntelligenceSDK

class MockAnalyticsModule: NSObject, AnalyticsModuleProtocol {
    
    public func startup(completion: @escaping (Bool) -> ()) {
        completion(true)
    }


    var trackedEvents:[Event] = []
    
    func pause() {
        
    }
    
    func resume() {
        
    }
    
    func track(event: Event) {
        trackedEvents += [event]
    }
    
    /// Track user engagement and behavioral insight.
    /// - parameter screenName: An identifier for the screen.
    /// - parameter viewingDuration: The time (in seconds) spent on the screen.
    func trackScreenViewed(_ screenName: String, viewingDuration: TimeInterval) {
        
    }
    
//    func startup(_ completion: (_ success: Bool) -> ()) {
//        completion(true)
//    }
    
    func shutdown() {
        
    }
}
