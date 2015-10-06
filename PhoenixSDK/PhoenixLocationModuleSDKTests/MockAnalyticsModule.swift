//
//  MockAnalyticsModule.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 06/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit

@testable import PhoenixSDK

class MockAnalyticsModule: NSObject, PhoenixAnalytics {

    var trackedEvents:[Phoenix.Event] = []
    
    func track(event:Phoenix.Event) {
        trackedEvents += [event]
    }
    
    func startup() {
        
    }
    
    func shutdown() {
        
    }
}
