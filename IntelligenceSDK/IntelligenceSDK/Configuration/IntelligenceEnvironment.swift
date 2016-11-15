//
//  IntelligenceEnvironment.swift
//  IntelligenceSDK
//
//  Created by Michael Lake on 13/01/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import Foundation

public extension Intelligence {
    
    /// An enum with the environments to which the SDK can be pointing to.
    @objc public enum Environment : Int {

        /// Local Environment
        case Local
        
        /// Development Environment
        case Development
        
        /// Integration Environment
        case Integration
        
        /// UAT Environment
        case UAT
        
        /// Staging Environment
        case Staging
        
        /// Production Environment
        case Production
        
        
        /// This init method should be used to extract the environment from a configuration file and turn it into an enum value
        /// The values that should be used are "local", "development", "integration", "uat", "staging" and "production"
        /// If another value is used this will return nil
        init?(code: String) {
            switch code {
            case "local":
                self = .Local
            case "development":
                self = .Development
            case "integration":
                self = .Integration
            case "uat":
                self = .UAT
            case "staging":
                self = .Staging
            case "production":
                self = .Production
            default:
                return nil
            }
        }
    }
}
