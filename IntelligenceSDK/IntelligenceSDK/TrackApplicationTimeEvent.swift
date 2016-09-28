//
//  TrackApplicationTimeEvent.swift
//  IntelligenceSDK
//
//  Created by Chris Nevin on 09/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class TrackApplicationTimeEvent: Event {
    
    static let EventType = "Intelligence.Analytics.Application.Time"
    
    init(withSeconds seconds: UInt64) {
        super.init(withType: TrackApplicationTimeEvent.EventType)
        self.value = Double(seconds)
    }
}
