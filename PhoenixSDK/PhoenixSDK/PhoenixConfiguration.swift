//
//  Configuration.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 21/07/2015.
//  Copyright (c) 2015 Tigerspike. All rights reserved.
//

import Foundation

/**
 This class holds the data to configure the phoenix SDK. It provides initialisers to
read the configuration from a plist file, and allows.
*/
public class PhoenixConfiguration
{
    private static let clientIdKey = "phoenix_client_id";
    private static let clientSecretKey = "phoenix_client_secret";
    private static let phoenixProjectIdKey = "phoenix_project_id";
    private static let phoenixApplicationIdKey = "phoenix_application_id";
    private static let phoenixRegionKey = "phoenix_region";
    private static let phoenixEnvironmentKey = "phoenix_environment";
    
    /// The client ID
    public var clientId:String!;
    
    /// The client secret
    public var clientSecret:String!;
    
    /// Default initializer. Does nothing.
    public init() {
        
    }
    
    /// Initialises the configuration with a plist with the file name specified in the main
    convenience public init (fromFile fileName:String!,inBundle bundle:NSBundle!) throws {
        self.init();
        try readFromFile(fileName, inBundle:bundle);
    }
    
    /// Reads the given file in the main bundle into the configuration.
    public func readFromFile(fileName:String!, inBundle bundle:NSBundle!) throws {
        if let plistResourcePath = bundle.pathForResource(fileName, ofType: "plist") {
            readFromPlistPath(plistResourcePath);
        }
        throw PhoenixGenericErrors.NoSuchConfigFile
    }
    
    private func readFromPlistPath(plistResourcePath:String!) -> Bool {
        if let plistData = NSDictionary(contentsOfFile: plistResourcePath) {
            
            if plistData[PhoenixConfiguration.clientIdKey] != nil {
                self.clientId = String(plistData[PhoenixConfiguration.clientIdKey]!);
            }
            
            if plistData[PhoenixConfiguration.clientSecretKey] != nil {
                self.clientSecret = String(plistData[PhoenixConfiguration.clientSecretKey]!);
            }
        }
        
        return false;
    }
}
