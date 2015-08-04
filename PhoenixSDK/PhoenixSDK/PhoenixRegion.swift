//
//  PhoenixRegion.swift
//  PhoenixSDK
//
//  Created by Chris Nevin on 22/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

public extension Phoenix {
    
    /// An enum with the regions to which the SDK can be pointing to.
    @objc public enum Region : Int {
        
        /// US Region
        case UnitedStates
        
        /// AU Region
        case Australia
        
        /// EU Region
        case Europe
        
        /// SG Region
        case Singapore
        
        /// NoRegion in case a non optional region needs to be initialized. Will fail 
        /// when calling baseURL.
        case NoRegion
        
        /// Asserts that it won't be called on .NoRegion.
        /// - Returns: String to the base url to use (including protocol).
        public func baseURL() -> String {
            switch (self) {
            case .UnitedStates:
                return "https://api.phoenixplatform.com"
            case .Australia:
                return "https://api.phoenixplatform.com.au"
            case .Europe:
                return "https://api.phoenixplatform.eu"
            case .Singapore:
                return "https://api.phoenixplatform.com.sg"
            default:
                assertionFailure("No base URL for no region")
                return ""
            }
        }
        
        /// - Returns: The region that a specific code represents. Returns nil if the
        /// code does not match any region.
        init(code: String) {
            switch code {
            case "US":
                self = .UnitedStates
            case "AU":
                self = .Australia
            case "EU":
                self = .Europe
            case "SG":
                self = .Singapore
            default:
                self = .NoRegion
            }
        }
    }
}
