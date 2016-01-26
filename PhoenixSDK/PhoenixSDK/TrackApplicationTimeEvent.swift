//
//  TrackApplicationTimeEvent.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 09/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

class TrackApplicationTimeEvent: Event {
    init(withSeconds seconds: UInt64) {
        super.init(withType: Event.ApplicationTimeEventType)
        self.value = Double(seconds)
    }
}
