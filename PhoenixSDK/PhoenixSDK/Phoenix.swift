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
    
    // MARK: Modules
    
    /// The identity module, used to manage users in the Phoenix backend.
    @objc public internal(set) var identity:PhoenixIdentity

    // MARK: Instance variables

    /// Private configuration. Can't be modified once initialized.
    /// Provide a Phoenix.Configuration object to initialize it.
    private let configuration: PhoenixConfigurationProtocol
    
    /// The network manager instance.
    internal let network: Network

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
    
    // MARK: Initializer
    
    /// Initializes the Phoenix entry point with a configuration object.
    /// - Parameters:
    ///     - phoenixConfiguration: The configuration to use. The configuration
    /// will be copied and kept privately to avoid future mutability.
    ///     - withTokenStorage: The token storage to be used.
    /// - Throws: **ConfigurationError** if the configuration is invalid
    public init(withConfiguration phoenixConfiguration: PhoenixConfigurationProtocol, withTokenStorage tokenStorage:TokenStorage) throws {
        self.configuration = phoenixConfiguration.clone()
        self.network = Network(withConfiguration: self.configuration, withTokenStorage:tokenStorage)

        // Modules
        self.identity = Identity(withNetwork: network, withConfiguration: configuration)

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
    ///     - withTokenStorage: The token storage to use.
    convenience public init(withFile: String, inBundle: NSBundle=NSBundle.mainBundle(), withTokenStorage tokenStorage:TokenStorage) throws {
        try self.init(withConfiguration: Configuration.configuration(fromFile: withFile, inBundle: inBundle), withTokenStorage: tokenStorage)
    }

    /// Initializes the Phoenix entry point with a configuration object. Will use the PhoenixKeychain token storage.
    /// - Parameters:
    ///     - phoenixConfiguration: The configuration to use. The configuration
    /// will be copied and kept privately to avoid future mutability.
    /// - Throws: **ConfigurationError** if the configuration is invalid
    convenience public init(withConfiguration phoenixConfiguration: PhoenixConfigurationProtocol) throws {
        try self.init(withConfiguration:phoenixConfiguration, withTokenStorage:PhoenixKeychain())
    }
    
    /// Provides a convenience initializer to load the configuration from a JSON file. Will use the PhoenixKeychain token storage.
    /// - Throws: **ConfigurationError** if the configuration is invalid or there is a problem
    /// reading the file.
    /// - Parameters:
    ///     - withFile: The JSON file name (no extension) of the configuration.
    ///     - inBundle: The bundle to use. Defaults to the main bundle.
    convenience public init(withFile: String, inBundle: NSBundle=NSBundle.mainBundle()) throws {
        try self.init(withFile:withFile, inBundle:inBundle, withTokenStorage: PhoenixKeychain())
    }
    
    // MARK:- Startup/Shutdown
    
    // TODO: Need to define how this works, since it can fail...
    // Strange flow, startup method actually makes a network call, so it's
    // a little odd that the user has to have internet access and the
    // platform is available for the app to start, need to rethink this.
    /// Starts up the Phoenix SDK.
    public func startup() {
        // Login as Application User.
        network.enqueueAuthenticationOperationIfRequired()
    }
    
    /// Shutdowns the Phoenix SDK.
    public func shutdown() {
        
    }
}