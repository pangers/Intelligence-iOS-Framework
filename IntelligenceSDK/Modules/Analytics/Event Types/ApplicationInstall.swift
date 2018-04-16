//
//  ApplicationInstall.swift
//  IntelligenceSDK
//
//  Created by chethan.palaksha on 18/1/17.
//  Copyright © 2017 Tigerspike. All rights reserved.
//

import Foundation

/// Event that gets fired when a Application get installed.
class ApplicationInstall: Event {

    static let EventType = EventTypes.ApplicationInstall.rawValue

    init() {
        super.init(withType: ApplicationInstall.EventType, value: 0, metadata: nil)
    }
}
