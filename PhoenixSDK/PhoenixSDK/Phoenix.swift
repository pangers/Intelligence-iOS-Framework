//
//  Phoenix.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 22/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Error occurred, probably network related.
public typealias PhoenixErrorCallback = (NSError) -> ()

/// The main Phoenix entry point. Aggregates modules in it.
public final class Phoenix: NSObject {
    
    /// Private configuration. Can't be modified once initialized.
    /// Provide a Phoenix.Configuration object to initialize it.
    private let myConfiguration: PhoenixConfigurationProtocol
    
    /// Called by Phoenix when the SDK does not know how to deal with
    /// the current error it has encountered.
    internal var errorCallback: PhoenixErrorCallback?
    
    /// The network manager instance.
    internal let network: Network
    
    // MARK: Initializers
    
    /// Initializes the Phoenix entry point with a configuration object.
    /// - Parameters:
    ///     - phoenixConfiguration: The configuration to use. The configuration
    /// will be copied and kept privately to avoid future mutability.
    ///     - withTokenStorage: The token storage to be used.
    ///     - errorCallback: Callback that handles very bad errors requiring developer action. These will usually be related to networking and therefore do not throw an exception.
    /// - Throws: **ConfigurationError** if the configuration is invalid
    public init(withConfiguration phoenixConfiguration: PhoenixConfigurationProtocol, withTokenStorage:TokenStorage) throws {
        self.myConfiguration = phoenixConfiguration.clone()
        self.network = Network(withConfiguration: self.myConfiguration, withTokenStorage: withTokenStorage)
        self.identity = Identity(withNetwork: network, withConfiguration: myConfiguration)
        
        super.init()
        
        if (self.myConfiguration.hasMissingProperty) {
            throw ConfigurationError.MissingPropertyError
        }
        if (!self.myConfiguration.isValid) {
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
    
    // MARK: Instance variables
    
    /// - Returns: A **copy** of the configuration.
    public var configuration: PhoenixConfigurationProtocol {
        return myConfiguration.clone()
    }
    
    // MARK: Modules
    
    /// The identity module, used to manage users in the Phoenix backend.
    @objc public internal(set) var identity:PhoenixIdentity

    // TODO: Need to define how this works, since it can fail...
    // Strange flow, startup method actually makes a network call, so it's
    // a little odd that the user has to have internet access and the
    // platform is available for the app to start, need to rethink this.
    /// Starts up the Phoenix SDK modules.
    /// - Parameter callback: Called when Phoenix SDK cannot resolve an issue. Interrogate NSError object to determine what happened.
    public func startup(callback: PhoenixErrorCallback) {
        // Login as Application User.
        self.errorCallback = callback
        network.enqueueAuthenticationOperationIfRequired()
    }
    
    /// Shutdowns the Phoenix SDK modules.
    public func shutdown() {
        
    }
}