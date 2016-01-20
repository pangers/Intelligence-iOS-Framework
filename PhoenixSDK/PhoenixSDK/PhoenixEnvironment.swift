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
        
        /// NoEnvironment in case a non optional environment needs to be initialized. Will fail
        /// when calling baseURL.
        case NoEnvironment
        
        /// - Returns: environment as a String, or nil if .NoEnvironment
        public func urlEnvironment() -> String? {
            switch (self) {
            case .UAT:
                return "uat"
            case .Production:
                return ""
            default:
                return nil
            }
        }
        
        /// - Returns: The environment that a specific code represents. Returns nil if the
        /// code does not match any environment.
        init(code: String) {
            switch code {
            case "uat":
                self = .UAT
            case "production":
                self = .Production
            default:
                self = .NoEnvironment
            }
        }
    }
}
