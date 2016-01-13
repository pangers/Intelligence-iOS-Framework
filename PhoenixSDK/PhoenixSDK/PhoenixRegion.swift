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
        
        /// - Returns: domain as a String, or nil if .NoRegion
        public func urlDomain() -> String? {
            switch (self) {
            case .UnitedStates:
                return ".com"
            case .Australia:
                return ".com.au"
            case .Europe:
                return ".eu"
            case .Singapore:
                return ".com.sg"
            default:
                return nil
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
