//
//  IntelligenceManager.swift
//  IntelligenceDemo-Swift
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import IntelligenceSDK

class IntelligenceManager {

    // This variable may be nil if startup has not been called successfully.
    internal private(set) static var intelligence: Intelligence?
    
    static func startup(with intelligence:Intelligence) {
        IntelligenceManager.intelligence = intelligence
    }
}
