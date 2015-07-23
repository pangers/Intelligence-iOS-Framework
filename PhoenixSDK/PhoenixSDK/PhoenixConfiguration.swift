//
//  Configuration.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 21/07/2015.
//  Copyright (c) 2015 Tigerspike. All rights reserved.
//

import Foundation

public extension Phoenix {
    
    /// This class holds the data to configure the phoenix SDK. It provides initialisers to
    /// read the configuration from a JSON file in an extension, and allows to validate that
    /// the data contained is valid to initialise the Phoenix SDK.
    public class Configuration: NSObject {
        
        /// The client ID
        public var clientID: String = ""
        
        /// The client secret
        public var clientSecret: String = ""
        
        /// The project ID
        public var projectID: Int = 0
        
        /// The application ID
        public var applicationID: Int = 0
        
        /// The region
        public var region: Region?

        // NSCopying
        public override func copy() -> AnyObject {
            let copy = Configuration()
            copy.region = self.region
            copy.applicationID = self.applicationID
            copy.projectID = self.projectID
            copy.clientID = String(self.clientID)
            copy.clientSecret = String(self.clientSecret)
            return copy
        }
        
        /// - Returns: True if the configuration is correct and can be used to initialize
        /// the Phoenix SDK.
        public var isValid: Bool {
            // For now only check if there is a missing property.
            return !self.hasMissingProperty
        }
        
        /// - Returns: True if there is a missing property in the configuration
        public var hasMissingProperty: Bool {
            return clientID.isEmpty || clientSecret.isEmpty || projectID <= 0 ||
                applicationID <= 0 || region == nil
        }
    }
}

// Extension to add JSON file reading functionality.
public extension Phoenix.Configuration {
    
    // Constants used to parse the JSON file.
    private enum ConfigurationKey: String {
        case ClientID = "client_id"
        case ClientSecret = "client_secret"
        case ApplicationID = "application_id"
        case ProjectID = "project_id"
        case Region = "region"
    }
    
    /// Initialises the configuration with a JSON with the file name specified in the main
    /// - Throws: **ConfigurationError** if there was any error while reading and parsing the file.
    /// - Parameters:
    ///     - fromFile: The file name to read.
    ///     - inBundle: The bundle in which we will look for the file.
    convenience public init(fromFile fileName: String, inBundle bundle: NSBundle=NSBundle.mainBundle()) throws {
        self.init();
        try readFromFile(fileName, inBundle:bundle)
    }
    
    /// Parses the JSON configuration file passed as parameter into the configuration object.
    /// - Throws: **ConfigurationError** if there was any error while reading and parsing the file.
    /// - Parameters:
    ///     - fileName: The name of the JSON file containing the configuration.
    ///     - inBundle: The bundle in which we will look for the file.
    public func readFromFile(fileName: String, inBundle bundle: NSBundle=NSBundle.mainBundle()) throws {
        
        guard
            let path = bundle.pathForResource(fileName, ofType: "json"),
            let data = NSData(contentsOfFile: path)  else
        {
            throw ConfigurationError.FileNotFoundError
        }
        
        // Helper function to parse the data and return an optional instead of an error
        func optionalJSONData(data: NSData) -> NSDictionary? {
            do {
                return try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary
            }
            catch {
                // Swallow the error
            }
            return nil
        }
        
        // Guard that we have the json data parsed correctly
        guard let contents = optionalJSONData(data) else {
            throw ConfigurationError.InvalidFileError
        }
        
        // Helper function to load a value from a dictionary.
        func value<T>(forKey key: ConfigurationKey, inContents contents: NSDictionary) throws -> T {
            guard let output = contents[key.rawValue] as? T else {
                throw ConfigurationError.InvalidPropertyError
            }
            return output
        }
        
        // Fetch from the contents dictionary
        clientID = try value(forKey: .ClientID, inContents:contents)
        clientSecret = try value(forKey: .ClientSecret, inContents:contents)
        projectID = try value(forKey: .ProjectID, inContents:contents)
        applicationID = try value(forKey: .ApplicationID, inContents:contents)
        region = try Phoenix.Region(code: value(forKey: .Region, inContents:contents))
    }
}
