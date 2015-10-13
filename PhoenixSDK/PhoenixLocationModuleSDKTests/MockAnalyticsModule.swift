//
//  MockAnalyticsModule.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 06/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit

@testable import PhoenixSDK

class MockAnalyticsModule: NSObject, AnalyticsModuleProtocol {

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
    func trackScreenViewed(screenName: String, viewingDuration: NSTimeInterval) {
        
    }
    
    func startup(completion: (success: Bool) -> ()) {
        completion(success: true)
    }
    
    func shutdown() {
        
    }
}
