//
//  MockConfiguration.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 23/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

import PhoenixSDK

public class MockConfiguration: PhoenixConfigurationProtocol {
    
    /// The client ID
    public var clientID = ""
    
    /// The client secret
    public var clientSecret = ""
    
    /// The project ID
    public var projectID = 0
    
    /// The application ID
    public var applicationID = 0
    
    /// The region
    public var region: Region?
    
    public var isValid = false
    
    public var hasMissingProperty = false
    
    /// - Returns: Base URL to call.
    public var baseURL: NSURL? {
        guard let URLString = self.region?.baseURL(), URL = NSURL(string: URLString) else {
            return nil
        }
        return URL
    }
}

