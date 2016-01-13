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
    case Enviroment = "enviroment"
    case CompanyId = "company_id"
    case SDKUserRole = "sdk_user_role"
}

public extension Phoenix {
    
    /// This class holds the data to configure the phoenix SDK. It provides initialisers to
    /// read the configuration from a JSON file in an extension, and allows to validate that
    /// the data contained is valid to initialise the Phoenix SDK.
    @objc(PHXConfiguration) public class Configuration: NSObject {

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
        
        /// The role ID to assign to users the SDK creates
        public var sdkUserRole = 0
        
        /// The region
        public var region:Region
        
        /// The enviroment to connect to
        public var enviroment:Enviroment
        
        /// Default initializer.
        /// Sets region to .NoRegion so we can notice that the region is invalid.
        /// Sets enviroment to .NoEnviroment so we can notice that the enviroment is invalid.
        public override init() {
            self.region = .NoRegion
            self.enviroment = .NoEnviroment
            
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
            copy.region = self.region
            copy.enviroment = self.enviroment
            copy.applicationID = self.applicationID
            copy.projectID = self.projectID
            copy.clientID = String(self.clientID)
            copy.clientSecret = String(self.clientSecret)
            copy.companyId = companyId
            copy.sdkUserRole = sdkUserRole
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
            self.clientID = try value(forKey: .ClientID, inContents:contents)
            self.clientSecret = try value(forKey: .ClientSecret, inContents:contents)
            self.projectID = try value(forKey: .ProjectID, inContents:contents)
            self.applicationID = try value(forKey: .ApplicationID, inContents:contents)
            self.region = try Phoenix.Region(code: value(forKey: .Region, inContents:contents))
            self.enviroment = try Phoenix.Enviroment(code: value(forKey: .Enviroment, inContents:contents))
            self.companyId = try value(forKey: .CompanyId, inContents:contents)
            self.sdkUserRole = try value(forKey: .SDKUserRole, inContents: contents)
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
                applicationID <= 0 || region == .NoRegion || enviroment == .NoEnviroment || companyId <= 0 || sdkUserRole <= 0
        }
        
        /// - Returns: Optional base URL to call.
        var baseURL: NSURL? {
            guard let enviroment = self.enviroment.urlEnviroment(),
                let domain = self.region.urlDomain() else {
                   return nil
            }
            
            
            var url = "https://api."
            
            if (enviroment.characters.count > 0) {
                url += "\(enviroment)."
            }
            
            // If domain happended to have 0 characters it would not affet the url (as the domain contains the .)
            url += "phoenixplatform\(domain)"
            
            return NSURL(string: url)
        }
    }
}