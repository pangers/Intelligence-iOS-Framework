//
//  IntelligenceConfiguration.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 21/07/2015.
//  Copyright (c) 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Constants used to parse the JSON file.

private enum ConfigurationKey: String {
    case clientID = "client_id"
    case clientSecret = "client_secret"
    case applicationID = "application_id"
    case projectID = "project_id"
    case region = "region"
    case environment = "environment"
    case companyId = "company_id"
    case sdkUserRole = "sdk_user_role"
    case certificateTrustPolicy = "certificate_trust_policy"
}

/// This enum represents the certificate trust policy to apply when the Intelligence SDK connects to the server.
/// Certificate validity is defined by iOS and not by the SDK.
/// When receiving a certificate challenge from iOS, the SDK will apply the selected policy.

@objc public enum CertificateTrustPolicy: Int {
    case valid /// Trust only certificates that are considered valid by iOS. This is the default value
    case any /// Trust any certificate, independently of iOS considering it valid or invalid
    case anyNonProduction /// Trust only non-production certificates, which implies that the certificates in the production server will need to be considered valid by iOS and any other will be trusted


    /// This init method should be used to extract certificate_trust_policy from a configuration file (if it exists) and turn it into an enum value
    /// The values that should be used are "valid", "any" and "any_non_production"
    /// If another value is used we will return nil
    init?(key: String) {
        switch key {
        case "valid":
            self = .valid
        case "any":
            self = .any
        case "any_non_production":
            self = .anyNonProduction
        default:
            return nil
        }
    }

    var stringType: String? {
        switch self {
        case .valid:
            return "valid"
        case .any:
            return "any"
        case .anyNonProduction:
            return "any_non_production"
        }
    }
}

public extension Intelligence {

    /// This class holds the data to configure the intelligence SDK. It provides initialisers to
    /// read the configuration from a JSON file in an extension, and allows to validate that
    /// the data contained is valid to initialise the Intelligence SDK.

    @objc(INTConfiguration) public class Configuration: NSObject {

        /// The client ID
        public var clientID = ""

        /// The client secret
        public var clientSecret = ""

        /// The provider Id
        public let providerId = 300

        /// The company Id
        public var companyId = 0

        /// The project ID
        public var projectID = 0

        /// The application ID
        public var applicationID = 0

        /// The role ID to assign to users the SDK creates
        public var sdkUserRole = 0

        /// The trust policy to apply to server certificates.
        /// By default we will only trust valid certificates.
        public var certificateTrustPolicy = CertificateTrustPolicy.valid

        /// The region
        public var region: Region?

        /// The environment to connect to
        public var environment: Environment?

        /// Convenience initializer to load from a file.
        /// - Parameters:
        ///     - fromFile: The file name to read. The .json extension is appended to it.
        ///     - inBundle: The bundle that contains the given file.
        /// - Throws: A **ConfigurationError** if the configuration file is incorrectly formatted.
        public convenience init(fromFile file: String, inBundle bundle: Bundle = Bundle.main) throws {
            self.init()
            try self.readFromFile(fileName: file, inBundle: bundle)
        }

        public convenience init(fromData: Data) throws {
            self.init()
            try readFromData(data: fromData)
        }

        /// Factory method to initialize a configuration and return it.
        /// - Throws: A **ConfigurationError** if the configuration file is incorrectly formatted.
        /// - Parameters:
        ///     - fromFile: The file name to read. The .json extension is appended to it.
        ///     - inBundle: The bundle that contains the given file.
        /// - Returns: A configuration with the contents of the file.
        public class func configuration(fromFile file: String, inBundle bundle: Bundle = Bundle.main) throws -> Configuration {
            let configuration = Configuration()
            try configuration.readFromFile(fileName: file, inBundle: bundle)
            return configuration
        }

        /// - Returns: A copy of the configuration object.
        public func clone() -> Configuration {
            let copy = Configuration()
            copy.region = self.region
            copy.environment = self.environment
            copy.applicationID = self.applicationID
            copy.projectID = self.projectID
            copy.clientID = String(self.clientID)
            copy.clientSecret = String(self.clientSecret)
            copy.companyId = companyId
            copy.sdkUserRole = sdkUserRole
            copy.certificateTrustPolicy = self.certificateTrustPolicy
            return copy
        }

        /// Parses the JSON configuration file passed as parameter into the configuration object.
        /// - Throws: **ConfigurationError** if there was any error while reading and parsing the file.
        /// - Parameters:
        ///     - fileName: The name of the JSON file containing the configuration.
        ///     - inBundle: The bundle in which we will look for the file.
        public func readFromFile(fileName: String, inBundle bundle: Bundle = Bundle.main) throws {

            guard let path = bundle.path(forResource: fileName, ofType: "json"),
                  let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped) else {
                throw ConfigurationError.fileNotFoundError
            }

            // Guard that we have the json data parsed correctly
            guard let contents = data.int_jsonDictionary else {
                throw ConfigurationError.invalidFileError
            }

            // Helper function to load a value from a dictionary.
            func value<T>(forKey key: ConfigurationKey, inContents contents: [String: Any]) throws -> T {
                guard let output = contents[key.rawValue] as? T else {
                    throw ConfigurationError.missingPropertyError
                }
                return output
            }

            // Fetch from the contents dictionary
            self.clientID = try value(forKey: .clientID, inContents: contents)
            self.clientSecret = try value(forKey: .clientSecret, inContents: contents)
            self.projectID = try value(forKey: .projectID, inContents: contents)
            self.applicationID = try value(forKey: .applicationID, inContents: contents)

            guard let region = try Intelligence.Region(code: value(forKey: .region, inContents: contents)) else {
                throw ConfigurationError.invalidPropertyError
            }

            self.region = region

            guard let environment = try Intelligence.Environment(code: value(forKey: .environment, inContents: contents)) else {
                throw ConfigurationError.invalidPropertyError
            }

            self.environment = environment

            self.companyId = try value(forKey: .companyId, inContents: contents)
            self.sdkUserRole = try value(forKey: .sdkUserRole, inContents: contents)

            guard let certificateTrustPolicyKey = contents[ConfigurationKey.certificateTrustPolicy.rawValue] as? String,
                  let certificateTrustPolicy = CertificateTrustPolicy(key: certificateTrustPolicyKey) else {
                throw ConfigurationError.invalidPropertyError
            }

            self.certificateTrustPolicy = certificateTrustPolicy
        }


        public func readFromData(data: Data) throws {

            // Guard that we have the json data parsed correctly
            guard let contents = data.int_jsonDictionary else {
                throw ConfigurationError.invalidFileError
            }

            // Helper function to load a value from a dictionary.
            func value<T>(forKey key: ConfigurationKey, inContents contents: [String: Any]) throws -> T {
                guard let output = contents[key.rawValue] as? T else {
                    throw ConfigurationError.missingPropertyError
                }
                return output
            }

            // Fetch from the contents dictionary
            self.clientID = try value(forKey: .clientID, inContents: contents)
            self.clientSecret = try value(forKey: .clientSecret, inContents: contents)
            self.projectID = try value(forKey: .projectID, inContents: contents)
            self.applicationID = try value(forKey: .applicationID, inContents: contents)

            guard let region = try Intelligence.Region(code: value(forKey: .region, inContents: contents)) else {
                throw ConfigurationError.invalidPropertyError
            }

            self.region = region

            guard let environment = try Intelligence.Environment(code: value(forKey: .environment, inContents: contents)) else {
                throw ConfigurationError.invalidPropertyError
            }

            self.environment = environment

            self.companyId = try value(forKey: .companyId, inContents: contents)
            self.sdkUserRole = try value(forKey: .sdkUserRole, inContents: contents)

            guard let certificateTrustPolicyKey = contents[ConfigurationKey.certificateTrustPolicy.rawValue] as? String,
                  let certificateTrustPolicy = CertificateTrustPolicy(key: certificateTrustPolicyKey) else {
                throw ConfigurationError.invalidPropertyError
            }

            self.certificateTrustPolicy = certificateTrustPolicy
        }

        func getJsonData() -> Data? {

            guard let code = self.region?.regionCode,
                  let envStr = self.environment?.envString,
                  let policyStr = self.certificateTrustPolicy.stringType else {
                return nil
            }

            var dict: [String: Any] = [:]

            dict[ConfigurationKey.clientID.rawValue] = self.clientID
            dict[ConfigurationKey.clientSecret.rawValue] = self.clientSecret
            dict[ConfigurationKey.applicationID.rawValue] = self.applicationID
            dict[ConfigurationKey.projectID.rawValue] = self.projectID

            dict[ConfigurationKey.region.rawValue] = code
            dict[ConfigurationKey.environment.rawValue] = envStr
            dict[ConfigurationKey.certificateTrustPolicy.rawValue] = policyStr

            dict[ConfigurationKey.companyId.rawValue] = self.companyId
            dict[ConfigurationKey.sdkUserRole.rawValue] = self.sdkUserRole

            let data = dict.int_toJSONData()
            return data
        }

        /// - Returns: True if the configuration is correct and can be used to initialize
        /// the Intelligence SDK.
        @objc public var isValid: Bool {
            // For now only check if there is a missing property.
            return !self.hasMissingProperty
        }

        /// - Returns: True if there is a missing property in the configuration
        @objc public var hasMissingProperty: Bool {
            return clientID.isEmpty || clientSecret.isEmpty || projectID <= 0 ||
                    applicationID <= 0 || region == nil || environment == nil || companyId <= 0 || sdkUserRole <= 0
        }

        static func ==(lhs: Configuration, rhs: Configuration) -> Bool {
            return lhs.clientID == rhs.clientID &&
                    lhs.clientSecret == rhs.clientSecret &&
                    lhs.projectID == rhs.projectID &&
                    lhs.applicationID == rhs.applicationID &&
                    lhs.region == rhs.region &&
                    lhs.companyId == rhs.companyId &&
                    lhs.environment == rhs.environment &&
                    lhs.sdkUserRole == rhs.sdkUserRole
        }
    }

}



