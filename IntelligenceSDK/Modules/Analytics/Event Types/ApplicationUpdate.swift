//
//  ApplicationUpdate.swift
//  IntelligenceSDK
//
//  Created by chethan.palaksha on 18/1/17.
//  Copyright © 2017 Tigerspike. All rights reserved.
//

import Foundation

/// Event that gets fired when a application get updated.
class ApplicationUpdate: Event {

    static let EventType = EventTypes.ApplicationUpdate.rawValue

    init() {
        super.init(withType: ApplicationUpdate.EventType, value: 0, metadata: nil)
    }
}
