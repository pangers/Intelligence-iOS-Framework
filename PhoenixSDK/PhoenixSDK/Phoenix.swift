//
//  Phoenix.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 22/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// The main Phoenix entry point. Aggregates modules in it.
public final class Phoenix: NSObject {
    
    // MARK: Instance variables

    /// Private configuration. Can't be modified once initialized.
    /// Provide a Phoenix.Configuration object to initialize it.
    private let configuration: PhoenixConfigurationProtocol
    
    /// The network manager instance.
    internal let network: Network

    /// Returns true if Phoenix is currently authenticated against the backend
    public var isAuthenticated:Bool {
        return network.isAuthenticated
    }

    /// - Returns: A **copy** of the configuration.
    public var currentConfiguration: PhoenixConfigurationProtocol {
        return configuration.clone()
    }
    
    /// Delegate implementing failure methods that a developer should implement to catch
    /// errors that the Phoenix SDK is unable to handle.
    /// - SeeAlso: `PhoenixNetworkDelegate`
    public var networkDelegate: PhoenixNetworkDelegate? {
        get {
            return network.delegate
        }
        set {
            network.delegate = newValue
        }
    }
    
    // MARK: The Phoenix SDK modules
    
    /// The identity module, used to manage users in the Phoenix backend.
    public internal(set) var identity:PhoenixIdentity?

    // MARK: Initializer
    
    /// Initializes the Phoenix entry point with a configuration object.
    /// - Parameter phoenixConfiguration: The configuration to use. The configuration
    /// will be copied and kept privately to avoid future mutability.
    /// - Throws: **ConfigurationError** if the configuration is invalid
    public init(withConfiguration phoenixConfiguration: PhoenixConfigurationProtocol) throws {
        self.configuration = phoenixConfiguration.clone()
        self.network = Network(withConfiguration: self.configuration)

        // Modules
        self.identity = Identity(withNetwork:network)

        super.init()
        
        if (self.configuration.hasMissingProperty)
        {
            throw ConfigurationError.MissingPropertyError
        }
        
        if (!self.configuration.isValid)
        {
            throw ConfigurationError.InvalidPropertyError
        }
    }
    
    /// Provides a convenience initializer to load the configuration from a JSON file
    /// - Throws: **ConfigurationError** if the configuration is invalid or there is a problem
    /// reading the file.
    /// - Parameters:
    ///     - withFile: The JSON file name (no extension) of the configuration.
    ///     - inBundle: The bundle to use. Defaults to the main bundle.
    convenience public init(withFile: String, inBundle: NSBundle=NSBundle.mainBundle()) throws {
        try self.init(withConfiguration: Configuration.configuration(fromFile: withFile, inBundle: inBundle))
    }

    // MARK:- Authentication

    /// Starts up the Phoenix SDK, triggering:
    ///   - Anonymous authentication
    public func startup() {
        network.performAuthentication { (authenticated) -> () in
            // Nop
        }
    }
    
    /// Shutdowns the Phoenix SDK.
    public func shutdown() {
        
    }
}