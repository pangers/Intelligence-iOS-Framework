//
//  Phoenix.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 22/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// The main Phoenix entry point. Aggregates modules in it.
public class Phoenix: NSObject {

    /// Private configuration. Can't be modified once initialized.
    private let configuration: Configuration
    
    /// - Returns: A **copy** of the configuration.
    public var currentConfiguration: Configuration {
        return configuration.copy() as! Configuration
    }
    
    /// Initializes the Phoenix entry point with a configuration object.
    /// - Parameter phoenixConfiguration: The configuration to use. The configuration
    /// will be copied to avoid future mutability.
    public init(withConfiguration cfg: Configuration) throws {
        self.configuration = cfg.copy() as! Configuration
        super.init()

        if ( cfg.hasMissingProperty() )
        {
            throw ConfigurationError.MissingPropertyError
        }

        if ( !cfg.isValid() )
        {
            throw ConfigurationError.InvalidPropertyError
        }
    }
    
    /// Provides a convenience initializer with a file and bundle.
    /// - Throws:
    /// **ConfigurationError.FileNotFoundError** error if the file is not found.
    /// **ConfigurationError.InvalidFileError** error if the file is in an invalid format.
    /// **ConfigurationError.InvalidPropertyError** error if a property in the file is invalid.
    /// - Parameters:
    ///     - withFile: The JSON file name (no extension) of the configuration.
    ///     - inBundle: The bundle to use. Defaults to the main bundle.
    convenience public init(withFile: String, inBundle: NSBundle=NSBundle.mainBundle()) throws {
        try self.init(withConfiguration: Configuration(fromFile: withFile, inBundle: inBundle))
    }
}