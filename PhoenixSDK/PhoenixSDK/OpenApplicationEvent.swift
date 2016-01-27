//
//  OpenApplicationEvent.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 19/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Event that gets fired on `startup()` of SDK.
internal class OpenApplicationEvent: Event {
    
    static let EventType = "Phoenix.Identity.Application.Opened"
    
    init() {
        super.init(withType: OpenApplicationEvent.EventType)
    }
    
}