//
//  Configuration.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 21/07/2015.
//  Copyright (c) 2015 Tigerspike. All rights reserved.
//

import Foundation

// Constants used to parse the JSON file.
private enum ConfigurationKey: String {
    case ClientID = "client_id"
    case ClientSecret = "client_secret"
    case ApplicationID = "application_id"
    case ProjectID = "project_id"
    case Region = "region"
    case CompanyId = "company_id"
}

/// A protocol defining the Phoenix required configuration.
/// The implementation is Phoenix.Configuration.
public protocol PhoenixConfigurationProtocol {
    var clientID: String { get set }
    var clientSecret: String { get set }
    var projectID: Int { get set }
    var applicationID: Int { get set }
    var companyId: String { get set }
    var region: Phoenix.Region? { get set }
    var isValid: Bool { get }
    var hasMissingProperty: Bool { get }

    func clone() -> PhoenixConfigurationProtocol
}

/// Extension to the configuraiton protocol to verify whether the configuration provided is
/// valid or not. Also has the baseURL helper method.
/// This extension is used for internal purposes only, and should not be overriden by the 
/// developer.
extension PhoenixConfigurationProtocol {
    
    /// - Returns: True if the configuration is correct and can be used to initialize
    /// the Phoenix SDK.
    public var isValid: Bool {
        // For now only check if there is a missing property.
        return !self.hasMissingProperty
    }
    
    /// - Returns: True if there is a missing property in the configuration
    public var hasMissingProperty: Bool {
        return clientID.isEmpty || clientSecret.isEmpty || projectID <= 0 ||
            applicationID <= 0 || region == nil || companyId.isEmpty
    }
    
    /// - Returns: Base URL to call.
    public var baseURL: NSURL? {
        guard let URLString = self.region?.baseURL(), URL = NSURL(string: URLString) else {
            return nil
        }
        return URL
    }
}

public extension Phoenix {
    
    /// This class holds the data to configure the phoenix SDK. It provides initialisers to
    /// read the configuration from a JSON file in an extension, and allows to validate that
    /// the data contained is valid to initialise the Phoenix SDK.
    public final class Configuration: NSObject, PhoenixConfigurationProtocol {
        
        /// The client ID
        public var clientID = ""
        
        /// The client secret
        public var clientSecret = ""

        /// The company Id
        public var companyId = ""

        /// The project ID
        public var projectID = 0
        
        /// The application ID
        public var applicationID = 0
        
        /// The region
        public var region: Region?

        /// Convenience initializer to load from a file.
        /// - Parameters:
        ///     - fromFile: The file name to read. The .json extension is appended to it.
        ///     - inBundle: The bundle that contains the given file.
        /// - Throws: A **ConfigurationError** if the configuration file is incorrectly formatted.
        convenience init(fromFile file:String, inBundle bundle:NSBundle) throws {
            self.init()
            try self.readFromFile(file, inBundle: bundle)
        }
        
        /// Factory method to initialize a configuration and return it.
        /// - Throws: A **ConfigurationError** if the configuration file is incorrectly formatted.
        /// - Parameters:
        ///     - fromFile: The file name to read. The .json extension is appended to it.
        ///     - inBundle: The bundle that contains the given file.
        /// - Returns: A configuration with the contents of the file.
        class func configuration(fromFile file:String, inBundle bundle:NSBundle) throws -> Configuration {
            let configuration = Configuration()
            try configuration.readFromFile(file, inBundle: bundle)
            return configuration
        }
        
        /// - Returns: A copy of the configuration object.
        public func clone() -> PhoenixConfigurationProtocol {
            let copy = Configuration()
            copy.region = self.region
            copy.applicationID = self.applicationID
            copy.projectID = self.projectID
            copy.clientID = String(self.clientID)
            copy.clientSecret = String(self.clientSecret)
            copy.companyId = companyId
            return copy
        }
        
        /// Parses the JSON configuration file passed as parameter into the configuration object.
        /// - Throws: **ConfigurationError** if there was any error while reading and parsing the file.
        /// - Parameters:
        ///     - fileName: The name of the JSON file containing the configuration.
        ///     - inBundle: The bundle in which we will look for the file.
        public func readFromFile(fileName: String, inBundle bundle: NSBundle=NSBundle.mainBundle()) throws {
            
            guard let path = bundle.pathForResource(fileName, ofType: "json"),
                data = NSData(contentsOfFile: path)  else
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
            self.clientID = try value(forKey: .ClientID, inContents:contents)
            self.clientSecret = try value(forKey: .ClientSecret, inContents:contents)
            self.projectID = try value(forKey: .ProjectID, inContents:contents)
            self.applicationID = try value(forKey: .ApplicationID, inContents:contents)
            self.region = try Phoenix.Region(code: value(forKey: .Region, inContents:contents))
            self.companyId = try value(forKey: .CompanyId, inContents:contents)
        }
    }
}
