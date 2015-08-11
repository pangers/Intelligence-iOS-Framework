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
    
    /// - Returns: A **copy** of the configuration.
    public var configuration: Phoenix.Configuration
    
    /// Called by Phoenix when the SDK does not know how to deal with
    /// the current error it has encountered.
    internal var errorCallback: PhoenixErrorCallback?
    
    /// The network manager instance.
    internal let network: Network
    
    // MARK: Initializers

    /// Initializes the Phoenix entry point with a configuration object.
    /// - Parameters:
    ///     - withConfiguration: The configuration to use. The configuration
    /// will be copied and kept privately to avoid future mutability.
    ///     - tokenStorage: The token storage to be used.
    /// - Throws: **ConfigurationError** if the configuration is invalid
    public init(withConfiguration phoenixConfiguration: Phoenix.Configuration, tokenStorage:TokenStorage) throws {
        self.configuration = phoenixConfiguration.clone()
        let myConfiguration = phoenixConfiguration.clone()
        self.network = Network(withConfiguration: myConfiguration, tokenStorage: tokenStorage)
        // Modules
        self.identity = Identity(withNetwork: network, withConfiguration: myConfiguration)
        self.location = Location(withNetwork: network, configuration: myConfiguration)

        super.init()
        
        if (myConfiguration.hasMissingProperty) {
            throw ConfigurationError.MissingPropertyError
        }
        if (!myConfiguration.isValid) {
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
        try self.init(withConfiguration: Configuration.configuration(fromFile: withFile, inBundle: inBundle), tokenStorage: tokenStorage)
    }

    /// Initializes the Phoenix entry point with a configuration object. Will use the PhoenixKeychain token storage.
    /// - Parameters:
    ///     - withConfiguration: The configuration to use. The configuration
    /// will be copied and kept privately to avoid future mutability.
    /// - Throws: **ConfigurationError** if the configuration is invalid
    convenience public init(withConfiguration phoenixConfiguration: Phoenix.Configuration) throws {
        try self.init(withConfiguration:phoenixConfiguration, tokenStorage:PhoenixKeychain())
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
    
    // MARK: Modules
    
    /// The identity module, used to manage users in the Phoenix backend.
    @objc public internal(set) var identity:PhoenixIdentity
    
    /// The location module, used to internally manages geofences and user location. Hidden from developers.
    internal(set) var location: Phoenix.Location
    
    // TODO: Need to define how this works, since it can fail...
    // Strange flow, startup method actually makes a network call, so it's
    // a little odd that the user has to have internet access and the
    // platform is available for the app to start, need to rethink this.
    /// Starts up the Phoenix SDK modules.
    /// - Parameter callback: Called when Phoenix SDK cannot resolve an issue. Interrogate NSError object to determine what happened.
    // Starts up modules. 
    // Anonymously logins into the SDK then:
    // - Cannot request anything on behalf of the user.
    // - Calls Application Installed/Updated.
    // - Ask for user location. (Developer does this, then notifies module (or automated)).
    // - Initialises Geofence load/download.
    // - Startup Events module, send stored events.
    // - Register for Push notifications. (Developer does this, then passes to module).
    public func startup(callback: PhoenixErrorCallback) {
        // Login as Application User.
        self.errorCallback = callback
        network.enqueueAuthenticationOperationIfRequired()
    }
    
    /// Shutdowns the Phoenix SDK modules.
    public func shutdown() {
        
    }
}