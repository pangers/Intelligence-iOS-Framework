//
//  ScreenViewedEvent.swift
//  PhoenixSDK
//
//  Created by Michael Lake on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Event that the developer can fire once a screen has been viewed
internal class ScreenViewedEvent: Event {
    
    init(screenName: String, viewingDuration: NSTimeInterval) {
        super.init(withType: Event.ApplicationScreenViewedEventType, value:viewingDuration, targetId: screenName, metadata:nil)
    }
    
}