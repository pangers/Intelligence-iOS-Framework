//
//  Configuration.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 21/07/2015.
//  Copyright (c) 2015 Tigerspike. All rights reserved.
//

import Foundation

public extension Phoenix {
    
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
        
        /// - Returns: String to the base url to use (including protocol).
        func baseURL() -> String {
            switch (self) {
            case .UnitedStates: return "https://api.phoenixplatform.com"
            case .Australia:    return "https://api.phoenixplatform.com.au"
            case .Europe:       return "https://api.phoenixplatform.eu"
            case .Singapore:    return "https://api.phoenixplatform.com.sg"
            }
        }
        
        static func fromString(str: String) -> Region? {
            switch str {
            case "US": return .UnitedStates
            case "AU": return .Australia
            case "EU": return .Europe
            case "SG": return .Singapore
            default:   return nil
            }
        }
    }

    /// Errors that can occur during Configuration.
    public enum ConfigurationError: Int, ErrorType {
        case FileNotFoundError
        case InvalidPropertyError
        case InvalidFileError
        case MissingPropertyError
    }
    
    /// This class holds the data to configure the phoenix SDK. It provides initialisers to
    /// read the configuration from a JSON file, and allows.
    @objc(PHXConfiguration)
    public class Configuration: NSObject {
        private enum ConfigurationKey: String {
            case ClientID = "client_id"
            case ClientSecret = "client_secret"
            case ApplicationID = "application_id"
            case ProjectID = "project_id"
            case Region = "region"
        }
        
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
        
        /// Initialises the configuration with a JSON with the file name specified in the main
        ///
        /// - Parameters
        ///     - fromFile: The file name to read.
        ///     - inBundle: The bundle in which we will look for the file.
        convenience public init(fromFile fileName:String, inBundle bundle: NSBundle=NSBundle.mainBundle()) throws {
            self.init();
            try readFromFile(fileName, inBundle:bundle)
        }
        
        /// Reads the given json file in the main bundle into the configuration.
        /// #### Throws
        /// **PhoenixError.NoSuchConfigFile** error if the file is not found.
        /// - Parameters:
        ///     - fileName: The name of the file with the configuration.
        ///     - inBundle: The bundle in which we will look for the file.
        public func readFromFile(fileName: String, inBundle bundle: NSBundle=NSBundle.mainBundle()) throws {
            guard let jsonResourcePath = bundle.pathForResource(fileName, ofType: "json") else {
                throw ConfigurationError.FileNotFoundError
            }
            try readFromJSONPath(jsonResourcePath)
        }
        
        /// Reads a json file at the given path into the configuration
        ///
        /// - Parameter jsonResourcePath: The path to the file. Obtained via NSBundle.pathForResource.
        /// - Returns: A boolean with true if and only if the file in `jsonResourcePath` is found and data is loaded from it.
        private func readFromJSONPath(path: String) throws {
            guard let data = NSData(contentsOfFile: path) else {
                throw ConfigurationError.FileNotFoundError
            }
            let contents: NSDictionary
            do {
                if let jsonData = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? NSDictionary {
                    contents = jsonData
                } else {
                    throw ConfigurationError.InvalidFileError
                }
            } catch {
                // Return InvalidFileError
                throw ConfigurationError.InvalidFileError
            }
            func value(forKey key: ConfigurationKey) throws -> String {
                guard let value = contents[key.rawValue] as? String where !value.isEmpty else {
                    throw ConfigurationError.InvalidPropertyError
                }
                return value
            }
            clientID = try value(forKey: .ClientID)
            clientSecret = try value(forKey: .ClientSecret)
            projectID = try Int(value(forKey: .ProjectID)) ?? 0
            applicationID = try Int(value(forKey: .ApplicationID)) ?? 0
            region = try Region.fromString(value(forKey: .Region))
        }
        
        /// Internal function used by Phoenix initialization to determine if Configuration object provided passes validation.
        func validate() -> Bool {
            return !clientID.isEmpty && !clientSecret.isEmpty && projectID > 0 &&
                applicationID > 0 && region != nil
        }
        
        public override func copy() -> AnyObject {
            let copy = Configuration()
            copy.region = self.region
            copy.applicationID = self.applicationID
            copy.projectID = self.projectID
            copy.clientID = String(self.clientID)
            copy.clientSecret = String(self.clientSecret)
            return copy
        }
    }
}
