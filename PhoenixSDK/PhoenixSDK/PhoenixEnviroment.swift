//
//  PhoenixEnviroment.swift
//  PhoenixSDK
//
//  Created by Michael Lake on 13/01/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import Foundation

public extension Phoenix {
    
    /// An enum with the enviroments to which the SDK can be pointing to.
    @objc public enum Enviroment : Int {
        
        /// UAT Enviroment
        case UAT
        
        /// Production Enviroment
        case Production
        
        /// NoEnviroment in case a non optional enviroment needs to be initialized. Will fail
        /// when calling baseURL.
        case NoEnviroment
        
        /// - Returns: enviroment as a String, or nil if .NoEnviroment
        public func urlEnviroment() -> String? {
            switch (self) {
            case .UAT:
                return "uat"
            case .Production:
                return ""
            default:
                return nil
            }
        }
        
        /// - Returns: The enviroment that a specific code represents. Returns nil if the
        /// code does not match any enviroment.
        init(code: String) {
            switch code {
            case "uat":
                self = .UAT
            case "production":
                self = .Production
            default:
                self = .NoEnviroment
            }
        }
    }
}
