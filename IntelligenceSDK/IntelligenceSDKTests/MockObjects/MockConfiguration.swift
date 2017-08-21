//
//  MockConfiguration.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 23/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

import IntelligenceSDK

  class MockConfiguration: Intelligence.Configuration {

    open var mockInvalid:Bool = false
    open var mockMissingProperty: Bool = false
    
    override init() {
        super.init()
        self.clientID = "123"
        self.clientSecret = "123"
        self.projectID = 123
        self.applicationID = 123
//        self.companyId = 12
        self.region = .europe
        self.environment = .uat
    }
    
    /// - Returns: A copy of the configuration object.
    override open func clone() -> MockConfiguration {
        let copy = MockConfiguration()
        copy.region = self.region
        copy.environment = self.environment
        copy.applicationID = self.applicationID
        copy.projectID = self.projectID
        copy.clientID = String(self.clientID)
        copy.clientSecret = String(self.clientSecret)
//        copy.companyId = companyId
        copy.mockInvalid = mockInvalid
        copy.mockMissingProperty = mockMissingProperty
        return copy
    }

    /// - Returns: True if the configuration is correct and can be used to initialize
    /// the Intelligence SDK.
    override open var isValid: Bool {
        if mockInvalid {
            return false
        }
        // For now only check if there is a missing property.
        return !super.isValid
    }
    
    /// - Returns: True if there is a missing property in the configuration
    override open var hasMissingProperty: Bool {
        if mockMissingProperty {
            return true
        }
        return super.hasMissingProperty
    }
}
