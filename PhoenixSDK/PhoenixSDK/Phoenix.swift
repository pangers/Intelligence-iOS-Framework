//
//  Phoenix.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 22/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Callback for unhandled errors. Most likely related to networking.
public typealias PhoenixErrorCallback = (NSError) -> ()

/// Base class for initialization of the SDK. Developers must call 'startup' method to start modules.
public final class Phoenix: NSObject {
    
    /// - Returns: A **copy** of the configuration.
    public let configuration: Phoenix.Configuration
    
    /// Called by Phoenix when the SDK does not know how to deal with the current error it has encountered.
    internal var errorCallback: PhoenixErrorCallback?
    
    /// Array of modules used for calling startup/shutdown methods easily.
    internal var modules: [PhoenixModuleProtocol] {
        return [location, identity, analytics]
    }
    
    // MARK: Initializers
    
    /// Initializes the Phoenix entry point with a configuration object.
    /// - parameter withConfiguration: Instance of the Configuration class, object will be copied to avoid mutability.
    /// - parameter tokenStorage:      The object responsible for storing OAuth tokens.
    /// - throws: **ConfigurationError** if the configuration is invalid.
    /// - returns: New instance of the Phoenix SDK base class.
    internal init(withConfiguration phoenixConfiguration: Phoenix.Configuration, tokenStorage:TokenStorage) throws {
        configuration = phoenixConfiguration.clone()            // Copy for developers
        
        super.init()

        if phoenixConfiguration.hasMissingProperty {
            throw ConfigurationError.MissingPropertyError
        }
        
        if !phoenixConfiguration.isValid {
            throw ConfigurationError.InvalidPropertyError
        }

        // Create shared objects for modules
        let internalConfiguration = phoenixConfiguration.clone()    // Copy for SDK
        let network = Network()
        let installation = Phoenix.Installation(configuration: internalConfiguration,
            applicationVersion: NSBundle.mainBundle(),
            installationStorage: NSUserDefaults())
        let locationManager = PhoenixLocationManager()
        
        // Modules
        identity = Identity(withNetwork: network, configuration: internalConfiguration, installation: installation)
        analytics = Analytics(withNetwork: network, configuration: internalConfiguration, installation: installation)
        location = Location(withNetwork: network, configuration: internalConfiguration, locationManager: locationManager)
                
        let internalAnalytics = analytics as! Analytics
        let internalLocation = location as! Location
        
        internalAnalytics.locationProvider = (location as? PhoenixLocationProvider)
        internalLocation.analytics = analytics
    }
    
    /// Provides a convenience initializer to load the configuration from a JSON file.
    /// - parameter withFile:         The JSON file name (no extension) of the configuration.
    /// - parameter inBundle:         The NSBundle to use. Defaults to the main bundle.
    /// - parameter withTokenStorage: The object responsible for storing OAuth tokens.
    /// - throws: **ConfigurationError** if the configuration is invalid or there is a problem reading the file.
    /// - returns: New instance of the Phoenix SDK base class.
    convenience internal init(withFile: String, inBundle: NSBundle=NSBundle.mainBundle(), withTokenStorage tokenStorage:TokenStorage) throws {
        try self.init(withConfiguration: Configuration.configuration(fromFile: withFile, inBundle: inBundle), tokenStorage: tokenStorage)
    }
    
    /// Initializes the Phoenix entry point with a configuration object.
    /// - parameter withConfiguration: Instance of the Configuration class, object will be copied to avoid mutability.
    /// - throws: **ConfigurationError** if the configuration is invalid.
    /// - returns: New instance of the Phoenix SDK base class.
    convenience public init(withConfiguration phoenixConfiguration: Phoenix.Configuration) throws {
        try self.init(withConfiguration:phoenixConfiguration, tokenStorage:PhoenixKeychain())
    }
    
    /// Provides a convenience initializer to load the configuration from a JSON file.
    /// - parameter withFile:         The JSON file name (no extension) of the configuration.
    /// - parameter inBundle:         The NSBundle to use. Defaults to the main bundle.
    /// - throws: **ConfigurationError** if the configuration is invalid or there is a problem reading the file.
    /// - returns: New instance of the Phoenix SDK base class.
    convenience public init(withFile: String, inBundle: NSBundle=NSBundle.mainBundle()) throws {
        try self.init(withFile:withFile, inBundle:inBundle, withTokenStorage: PhoenixKeychain())
    }
    
    // MARK: Modules
    
    /// The identity module, enables user management in the Phoenix backend.
    @objc public internal(set) var identity: PhoenixIdentity!
    
    /// Analytics instance that can be used for posting Events.
    @objc public internal(set) var analytics: PhoenixAnalytics!
    
    /// The location module, used to internally manages geofences and user location. Hidden from developers.
    @objc public internal(set) var location: PhoenixLocation!
    
    /// Starts up the Phoenix SDK modules.
    /// - parameter callback: Called when Phoenix SDK cannot resolve an issue. Interrogate NSError object to determine what happened.
    public func startup(callback: PhoenixErrorCallback) {
        // Anonymously logins into the SDK then:
        // - Cannot request anything on behalf of the user.
        // - Calls Application Installed/Updated/Opened.
        // - Initialises Geofence load/download.
        // - Startup Events module, send stored events.
        errorCallback = callback
        modules.forEach {
            $0.startup()
        }
    }
    
    /// Shutdowns the Phoenix SDK modules.
    public func shutdown() {
        modules.forEach{
            $0.shutdown()
        }
    }
}