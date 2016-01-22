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
        
        
        /// This init method should be used to extract the region from a configuration file and turn it into an enum value
        /// The values that should be used are "US", "AU", "EU" and "SG"
        /// If another value is used we will create the .NoRegion enum value
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
