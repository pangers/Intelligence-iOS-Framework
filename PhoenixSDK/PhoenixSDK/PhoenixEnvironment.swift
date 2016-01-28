//
//  PhoenixEnvironment.swift
//  PhoenixSDK
//
//  Created by Michael Lake on 13/01/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import Foundation

public extension Phoenix {
    
    /// An enum with the environments to which the SDK can be pointing to.
    @objc public enum Environment : Int {
        
        /// UAT Environment
        case UAT
        
        /// Production Environment
        case Production
        
        
        /// This init method should be used to extract the environment from a configuration file and turn it into an enum value
        /// The values that should be used are "uat" and "production"
        /// If another value is used this will return nil
        init?(code: String) {
            switch code {
            case "uat":
                self = .UAT
            case "production":
                self = .Production
            default:
                return nil
            }
        }
    }
}
