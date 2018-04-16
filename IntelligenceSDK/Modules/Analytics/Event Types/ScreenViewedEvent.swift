//
//  ScreenViewedEvent.swift
//  IntelligenceSDK
//
//  Created by Michael Lake on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Event that the developer can fire once a screen has been viewed
@objc(INTScreenViewedEvent) public class ScreenViewedEvent: Event {

    static let EventType = "Phoenix.Identity.Application.ScreenViewed"

    @objc public init(screenName: String, viewingDuration: TimeInterval) {
        super.init(withType: ScreenViewedEvent.EventType, value: viewingDuration, targetId: screenName, metadata: ["Medium": "IOSSDK" as AnyObject])
    }

}
