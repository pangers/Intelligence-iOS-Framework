//
//  Phoenix.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 22/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Mandatory public protocol developers must implement in order to respond to events correctly.
@objc(PHXPhoenixDelegate)
public protocol PhoenixDelegate {
    /// Unable to create SDK user, this may occur if a user with the randomized
    /// credentials already exists (highly unlikely) or your Application is
    /// configured incorrectly and has the wrong permissions.
    func userCreationFailedForPhoenix(phoenix: Phoenix)
    
    /// User is required to login again, developer must implement this method
    /// you may present a 'Login Screen' or silently call identity.login with
    /// stored credentials.
    func userLoginRequiredForPhoenix(phoenix: Phoenix)
    
    /// Unable to assign provided sdk_user_role to your newly created user.
    /// This may occur if the Application is configured incorrectly in the backend
    /// and doesn't have the correct permissions or the role doesn't exist.
    func userRoleAssignmentFailedForPhoenix(phoenix: Phoenix)
}

/// Wrapping protocol used by modules to pass back errors to Phoenix.
internal protocol PhoenixInternalDelegate {
    // Implementation will call PhoenixDelegate.userCreationFailedForPhoenix
    func userCreationFailed()
    // Implementation will call PhoenixDelegate.userLoginRequiredForPhoenix
    func userLoginRequired()
    // Implementation will call PhoenixDelegate.userRoleAssignmentFailedForPhoenix
    func userRoleAssignmentFailed()
}

/// Base class for initialization of the SDK. Developers must call 'startup' method to start modules.
public final class Phoenix: NSObject, PhoenixInternalDelegate {
    
    /// - Returns: A **copy** of the configuration.
    public let configuration: Phoenix.Configuration
    
    /// Responsible for propogating events back to App.
    internal var delegate: PhoenixDelegate!
    
    // MARK: - Modules
    
    /// The identity module, enables user management in the Phoenix backend.
    @objc public internal(set) var identity: PhoenixIdentity!
    
    /// Analytics instance that can be used for posting Events.
    @objc public internal(set) var analytics: PhoenixAnalytics!
    
    /// The location module, used to internally manages geofences and user location. Hidden from developers.
    @objc public internal(set) var location: PhoenixLocation!
    
    /// Array of modules used for calling startup/shutdown methods easily.
    internal var modules: [PhoenixModuleProtocol] {
        return [location, identity, analytics]
    }
    
    // MARK: - Initializers
    
    /// (INTERNAL) Initializes the Phoenix entry point with a configuration object.
    /// - parameter delegate:      Object that responds to delegate events.
    /// - parameter configuration: Configuration object to configure instance of Phoenix with, will fail if configured incorrectly.
    /// - parameter oauthStorage:  Object responsible for storing OAuth information.
    /// - throws: **ConfigurationError** if the configuration is invalid.
    /// - returns: New instance of the Phoenix SDK base class.
    internal init(
        withDelegate delegate: PhoenixDelegate,
        configuration phoenixConfiguration: Phoenix.Configuration,
        oauthStorage: PhoenixOAuthStorage) throws
    {
        
        // TODO: Is this even required?? What's the point? They have the plist...
        configuration = phoenixConfiguration.clone()            // Copy for developers
        self.delegate = delegate
        super.init()

        if phoenixConfiguration.hasMissingProperty {
            throw ConfigurationError.MissingPropertyError
        }
        
        if !phoenixConfiguration.isValid {
            throw ConfigurationError.InvalidPropertyError
        }

        // Create shared objects for modules
        let internalConfiguration = phoenixConfiguration.clone()    // Copy for SDK
        let network = Network(delegate: self, oauthProvider: PhoenixOAuthDefaultProvider())
        let installation = Phoenix.Installation(configuration: internalConfiguration,
            applicationVersion: NSBundle.mainBundle(),
            installationStorage: NSUserDefaults())
        let locationManager = PhoenixLocationManager()
        
        // Modules
        identity = Identity(withDelegate: self, network: network, configuration: internalConfiguration, installation: installation)
        analytics = Analytics(withDelegate: self, network: network, configuration: internalConfiguration, installation: installation)
        location = Location(withDelegate: self, network: network, configuration: internalConfiguration, locationManager: locationManager)
                
        let internalAnalytics = analytics as! Analytics
        let internalLocation = location as! Location
        
        internalAnalytics.locationProvider = (location as? PhoenixLocationProvider)
        internalLocation.analytics = analytics
    }
    
    /// (INTERNAL) Provides a convenience initializer to load the configuration from a JSON file.
    /// - parameter delegate:      Object that responds to delegate events.
    /// - parameter oauthStorage:  Object responsible for storing OAuth information.
    /// - parameter file:          The JSON file name (no extension) of the configuration.
    /// - parameter inBundle:      The NSBundle to use. Defaults to the main bundle.
    /// - throws: **ConfigurationError** if the configuration is invalid or there is a problem reading the file.
    /// - returns: New instance of the Phoenix SDK base class.
    convenience internal init(
        withDelegate delegate: PhoenixDelegate,
        oauthStorage: PhoenixOAuthStorage,
        file: String,
        inBundle: NSBundle=NSBundle.mainBundle()) throws
    {
        try self.init(withDelegate: delegate, configuration: Configuration.configuration(fromFile: file, inBundle: inBundle), oauthStorage: oauthStorage)
    }
    
    /// Initializes the Phoenix entry point with a configuration object.
    /// - parameter delegate: The delegate to call for events propagated by Phoenix modules.
    /// - parameter configuration: Instance of the Configuration class, object will be copied to avoid mutability.
    /// - throws: **ConfigurationError** if the configuration is invalid.
    /// - returns: New instance of the Phoenix SDK base class.
    convenience public init(
        withDelegate delegate: PhoenixDelegate,
        configuration phoenixConfiguration: Phoenix.Configuration) throws
    {
        try self.init(withDelegate: delegate, configuration: phoenixConfiguration, oauthStorage:PhoenixKeychain())
    }
    
    /// Initialize Phoenix with a configuration file.
    /// - parameter delegate: The delegate to call for events propagated by Phoenix modules.
    /// - parameter file:     The JSON file name (no extension) of the configuration.
    /// - parameter inBundle: The NSBundle to use. Defaults to the main bundle.
    /// - throws: **ConfigurationError** if the configuration is invalid or there is a problem reading the file.
    /// - returns: New instance of the Phoenix SDK base class.
    convenience public init(
        withDelegate delegate: PhoenixDelegate,
        file: String,
        inBundle: NSBundle=NSBundle.mainBundle()) throws
    {
        try self.init(withDelegate: delegate, oauthStorage: PhoenixKeychain(), file:file, inBundle:inBundle)
    }
    
    /// Starts up the Phoenix SDK modules.
    /// - parameter callback: Called when Phoenix SDK cannot resolve an issue. Interrogate NSError object to determine what happened.
    public func startup(completion: (success: Bool) -> ()) {
        // Anonymously logins into the SDK then:
        // - Cannot request anything on behalf of the user.
        // - Calls Application Installed/Updated/Opened.
        // - Initialises Geofence load/download.
        // - Startup Events module, send stored events.
        
        identity.startup { [weak self] (success) -> () in
            if !success {
                completion(success: false)
                return
            }
            self?.analytics.startup({ [weak self] (success) -> () in
                if !success {
                    completion(success: false)
                    return
                }
                self?.location.startup({ (success) -> () in
                    completion(success: success)
                })
            })
        }
    }
    
    /// Shutdowns the Phoenix SDK modules.
    public func shutdown() {
        modules.forEach{
            $0.shutdown()
        }
    }
    
    // MARK:- PhoenixInternalDelegate
    
    internal func userCreationFailed() {
        delegate.userCreationFailedForPhoenix(self)
    }
    
    internal func userLoginRequired() {
        delegate.userLoginRequiredForPhoenix(self)
    }
    
    internal func userRoleAssignmentFailed() {
        delegate.userRoleAssignmentFailedForPhoenix(self)
    }
}