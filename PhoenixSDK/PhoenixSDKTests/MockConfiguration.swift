//
//  MockConfiguration.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 23/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

import PhoenixSDK

public struct MockConfiguration: PhoenixConfigurationProtocol {
    
    public var clientID: String = "123"
    public var clientSecret: String = "123"
    public var projectID: Int = 123
    public var applicationID: Int = 123
    public var region: Phoenix.Region? = .Europe
    
    public var mockInvalid:Bool = false
    public var mockMissingProperty: Bool = false

    /// - Returns: True if the configuration is correct and can be used to initialize
    /// the Phoenix SDK.
    public var isValid: Bool {
        if mockInvalid {
           return false
        }
        
        // For now only check if there is a missing property.
        return !self.hasMissingProperty
    }
    
    /// - Returns: True if there is a missing property in the configuration
    public var hasMissingProperty: Bool {
        if mockMissingProperty {
            return true
        }
        
        return clientID.isEmpty || clientSecret.isEmpty || projectID <= 0 ||
            applicationID <= 0 || region == nil
    }
    
    public func clone() -> PhoenixConfigurationProtocol {
        let tmp = self
        return tmp
    }
}