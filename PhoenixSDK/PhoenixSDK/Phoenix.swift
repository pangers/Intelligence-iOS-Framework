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
    private let configuration: PhoenixConfigurationProtocol
    internal let network: Network

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
    
    /// Initializes the Phoenix entry point with a configuration object.
    /// - Parameter phoenixConfiguration: The configuration to use. The configuration
    /// will be copied to avoid future mutability.
    /// - Throws: **ConfigurationError** if the configuration is invalid
    public init(withConfiguration cfg: PhoenixConfigurationProtocol) throws {
        self.configuration = cfg.clone()
        self.network = Network(withConfiguration: self.configuration)
        super.init()

        if (cfg.hasMissingProperty)
        {
            throw ConfigurationError.MissingPropertyError
        }

        if (!cfg.isValid)
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
    
    /// Attempt to authenticate with a username and password.
    /// - Parameters
    ///     - username: Username of account to attempt login with.
    ///     - password: Password associated with username.
    ///     - callback: Block/function to call once executed.
    public func login(withUsername username: String, password: String, callback: PhoenixAuthenticationCallback) {
        network.login(withUsername: username, password: password, callback: callback)
    }
    
    /// Logout of currently logged in user's account.
    public func logout() {
        network.logout()
    }
    
    /// Starts the Phoenix SDK work
    public func startup() {
        network.anonymousLogin { (authenticated) -> () in
            print("Logged in \(authenticated)")
        }
    }
    
}