//
//  UserCreated.Swift
//  IntelligenceSDK
//
//  Created by chethan.palaksha on 18/1/17.
//  Copyright © 2017 Tigerspike. All rights reserved.
//

import Foundation

/// Event that gets fired when a SDK user created.
internal class UserCreatedEvent: Event {
    
    static let EventType = EventTypes.UserCreated.rawValue
    
    init(user: Intelligence.User) {
        super.init(withType: UserCreatedEvent.EventType, value: 0, targetId: String(user.userId), metadata: nil)
    }
}
