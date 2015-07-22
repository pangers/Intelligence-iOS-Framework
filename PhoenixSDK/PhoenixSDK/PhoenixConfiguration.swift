//
//  Configuration.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 21/07/2015.
//  Copyright (c) 2015 Tigerspike. All rights reserved.
//

import Foundation

/// An enum with the regions to which the SDK can be pointing to.
public enum Region {
    /// US Region
    case UnitedStates
    
    /// AU Region
    case Australia
    
    /// EU Region
    case Europe
    
    /// SG Region
    case Singapore
    

    /// Provides the base url for the given Region.
    /// - Returns String: to the base url to use (including protocol).
    func baseURL() -> String {
        switch (self) {
        case .UnitedStates:
            return "TODO"
        case .Australia:
            return "TODO"
        case .Europe:
            return "TODO"
        case .Singapore:
            return "TODO"
        }
    }
}

/// This class holds the data to configure the phoenix SDK. It provides initialisers to
/// read the configuration from a plist file, and allows.
public class PhoenixConfiguration
{

    /// The client ID
    public var clientId:String!;
    
    /// The client secret
    public var clientSecret:String!;

    /// The project ID
    public var projectId:String!;

    /// The application ID
    public var applicationID:String!;

    /// The region
    public var region:Region!;

}

/// Extension to provide copy initializer
public extension PhoenixConfiguration {
    
    /// Copy initialiser.
    /// - Parameter PhoenixConfiguration: The phoenix configuration to copy.
    convenience public init(copying:PhoenixConfiguration){
        self.init()
        self.clientId = copying.clientId
        self.clientSecret = copying.clientSecret
        self.projectId = copying.projectId
        self.applicationID = copying.applicationID
        self.region = copying.region
    }
    
}


/// This extension encapsulates the file reading and parsing in the configuration
public extension PhoenixConfiguration {
    
    // Constants to load from a config file.
    private static let clientIdKey = "client_id"
    private static let clientSecretKey = "client_secret"
    private static let projectIdKey = "project_id"
    private static let applicationIdKey = "application_id"
    private static let regionKey = "region"
    
    /// Initialises the configuration with a plist with the file name specified in the main
    /// - Parameter fromFile: The file name to read.
    /// - Parameter inBundle: The bundle in which we will look for the file.
    convenience public init (fromFile fileName:String!,inBundle bundle:NSBundle!) throws {
        self.init();
        try readFromFile(fileName, inBundle:bundle)
    }
    
    /// Reads the given file in the main bundle into the configuration.
    /// Throws a PhoenixGenericErrors.NoSuchConfigFile error if the file is not found.
    /// - Parameter fileName: The name of the file with the configuration.
    /// - Parameter inBundle: The bundle in which we will look for the file.
    public func readFromFile(fileName:String!, inBundle bundle:NSBundle!) throws {
        if let plistResourcePath = bundle.pathForResource(fileName, ofType: "plist") {
            readFromPlistPath(plistResourcePath)
        }
        throw PhoenixGenericErrors.NoSuchConfigFile
    }
    
    /// Reads a plist file at the given path into the configuration
    /// - Parameter plistResourcePath: The path to the file. Obtained via NSBundle.pathForResource.
    /// - Returns: A boolean with true if and only if the file is found and data is loaded from it.
    private func readFromPlistPath(plistResourcePath:String!) -> Bool {
        if let plistData = NSDictionary(contentsOfFile: plistResourcePath) {
            
            if plistData[PhoenixConfiguration.clientIdKey] != nil {
                self.clientId = String(plistData[PhoenixConfiguration.clientIdKey]!)
            }
            
            if plistData[PhoenixConfiguration.clientSecretKey] != nil {
                self.clientSecret = String(plistData[PhoenixConfiguration.clientSecretKey]!)
            }
            
            return true;
        }
        
        return false;
    }

}
