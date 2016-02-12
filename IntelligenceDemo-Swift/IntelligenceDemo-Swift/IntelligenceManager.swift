//
//  IntelligenceManager.swift
//  IntelligenceDemo-Swift
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import IntelligenceSDK

class IntelligenceManager {
    
    internal private(set) static var intelligence:Intelligence!
        
    static func startupWithIntelligence(intelligence:Intelligence) {
        IntelligenceManager.intelligence = intelligence
    }
}