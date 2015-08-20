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
    case UseGeofences = "use_geofences"
}

public extension Phoenix {
    
    /// This class holds the data to configure the phoenix SDK. It provides initialisers to
    /// read the configuration from a JSON file in an extension, and allows to validate that
    /// the data contained is valid to initialise the Phoenix SDK.
    // TODO: Make final so Developers cannot override this!
    @objc(PHXConfiguration) public class Configuration: NSObject {
        
        /// Flag specifying whether or not to download geofences on launch.
        public var useGeofences = true
        
        /// The client ID
        public var clientID = ""
        
        /// The client secret
        public var clientSecret = ""

        /// The company Id
        public var companyId = 0

        /// The project ID
        public var projectID = 0
        
        /// The application ID
        public var applicationID = 0
        
        /// The region
        public var region:Region
        
        /// Default initializer. Sets region to .NoRegion so we can notice that the region is invalid.
        public override init() {
            self.region = .NoRegion
            super.init()
        }

        /// Convenience initializer to load from a file.
        /// - Parameters:
        ///     - fromFile: The file name to read. The .json extension is appended to it.
        ///     - inBundle: The bundle that contains the given file.
        /// - Throws: A **ConfigurationError** if the configuration file is incorrectly formatted.
        public convenience init(fromFile file:String, inBundle bundle:NSBundle=NSBundle.mainBundle()) throws {
            self.init()
            try self.readFromFile(file, inBundle: bundle)
        }
        
        /// Factory method to initialize a configuration and return it.
        /// - Throws: A **ConfigurationError** if the configuration file is incorrectly formatted.
        /// - Parameters:
        ///     - fromFile: The file name to read. The .json extension is appended to it.
        ///     - inBundle: The bundle that contains the given file.
        /// - Returns: A configuration with the contents of the file.
        public class func configuration(fromFile file:String, inBundle bundle:NSBundle=NSBundle.mainBundle()) throws -> Configuration {
            let configuration = Configuration()
            try configuration.readFromFile(file, inBundle: bundle)
            return configuration
        }
        
        /// - Returns: A copy of the configuration object.
        public func clone() -> Configuration {
            let copy = Configuration()
            copy.useGeofences = self.useGeofences
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
            
            // Guard that we have the json data parsed correctly
            guard let contents = data.phx_jsonDictionary else {
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
            do {
                self.useGeofences = try value(forKey: .UseGeofences, inContents: contents)
            }
            catch {
                self.useGeofences = true
            }
            self.clientID = try value(forKey: .ClientID, inContents:contents)
            self.clientSecret = try value(forKey: .ClientSecret, inContents:contents)
            self.projectID = try value(forKey: .ProjectID, inContents:contents)
            self.applicationID = try value(forKey: .ApplicationID, inContents:contents)
            self.region = try Phoenix.Region(code: value(forKey: .Region, inContents:contents))
            self.companyId = try value(forKey: .CompanyId, inContents:contents)
        }
        
        /// - Returns: True if the configuration is correct and can be used to initialize
        /// the Phoenix SDK.
        @objc public var isValid: Bool {
            // For now only check if there is a missing property.
            return !self.hasMissingProperty
        }
        
        /// - Returns: True if there is a missing property in the configuration
        @objc public var hasMissingProperty: Bool {
            return clientID.isEmpty || clientSecret.isEmpty || projectID <= 0 ||
                applicationID <= 0 || region == .NoRegion || companyId <= 0
        }
        
        /// - Returns: Optional base URL to call.
        var baseURL: NSURL? {
            // nil on no region
            if region == .NoRegion {
                return nil
            }
            
            return NSURL(string: self.region.baseURL())
        }
    }
}