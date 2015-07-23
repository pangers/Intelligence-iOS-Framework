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
    public enum Region {
        
        /// US Region
        case UnitedStates
        
        /// AU Region
        case Australia
        
        /// EU Region
        case Europe
        
        /// SG Region
        case Singapore
        
        /// - Returns: String to the base url to use (including protocol).
        func baseURL() -> String {
            switch (self) {
            case .UnitedStates:
                return "https://api.phoenixplatform.com"
            case .Australia:
                return "https://api.phoenixplatform.com.au"
            case .Europe:
                return "https://api.phoenixplatform.eu"
            case .Singapore:
                return "https://api.phoenixplatform.com.sg"
            }
        }
        
        /// - Returns: The region that a specific code represents. Can return nil if the
        /// code does not match any region.
        static func fromString(str: String) -> Region? {
            switch str {
            case "US":
                return .UnitedStates
            case "AU":
                return .Australia
            case "EU":
                return .Europe
            case "SG":
                return .Singapore
            default:
                return nil
            }
        }
    }
}
