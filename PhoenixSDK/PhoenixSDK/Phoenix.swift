//
//  Phoenix.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 22/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Mandatory public protocol developers must implement in order to respond to events correctly.
@objc(PHXDelegate)
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

internal class PhoenixDelegateWrapper: PhoenixInternalDelegate {
    
    var phoenix: Phoenix!
    var delegate: PhoenixDelegate!
    
    // MARK:- PhoenixInternalDelegate
    
    internal func userCreationFailed() {
        delegate.userCreationFailedForPhoenix(phoenix)
    }
    
    internal func userLoginRequired() {
        delegate.userLoginRequiredForPhoenix(phoenix)
    }
    
    internal func userRoleAssignmentFailed() {
        delegate.userRoleAssignmentFailedForPhoenix(phoenix)
    }
    
}


/// Base class for initialization of the SDK. Developers must call 'startup' method to start modules.
public final class Phoenix: NSObject {
    
    /// - Returns: A **copy** of the configuration.
    public let configuration: Phoenix.Configuration
    
    /// Responsible for propogating events back to App.
    internal var delegateWrapper: PhoenixDelegateWrapper!
    
    // MARK: - Modules
    
    /// The identity module, enables user management in the Phoenix backend.
    @objc public internal(set) var identity: IdentityModuleProtocol!
    
    /// Analytics instance that can be used for posting Events.
    @objc public internal(set) var analytics: AnalyticsModuleProtocol!
    
    /// The location module, used to internally manages geofences and user location. Hidden from developers.
    @objc public internal(set) var location: LocationModuleProtocol!
    
    /// Array of modules used for calling startup/shutdown methods easily.
    internal var modules: [ModuleProtocol] {
        return [identity, location, analytics]
    }
    
    // MARK: - Initializers
    
    /// (INTERNAL) Initializes the Phoenix entry point with all objects necessary.
    /// - parameter delegate:      Object that responds to delegate events.
    /// - parameter delegateWrapper: The delegate wrapper so we intercept calls to it.
    /// - parameter network:       Network object, responsible for sending all OAuth requests.
    /// - parameter configuration: Configuration object to configure instance of Phoenix with, will fail if configured incorrectly.
    /// - parameter oauthProvider:  Object responsible for storing OAuth information.
    /// - parameter installation:  Object responsible for reading installation information.
    /// - parameter locationManager: Location manager responsible for handling location updates.
    /// - throws: **ConfigurationError** if the configuration is invalid.
    /// - returns: New instance of the Phoenix SDK base class.
    internal init(
        withDelegate delegate: PhoenixDelegate,
        delegateWrapper: PhoenixDelegateWrapper,
        network: Network? = nil,
        configuration phoenixConfiguration: Phoenix.Configuration,
        oauthProvider: PhoenixOAuthProvider,
        installation: Installation,
        locationManager: LocationManager
        ) throws
    {
        self.configuration = phoenixConfiguration.clone()
        super.init()
        
        delegateWrapper.delegate = delegate
        delegateWrapper.phoenix = self
        
        let network = network ?? Network(delegate: delegateWrapper, oauthProvider: oauthProvider)
        
        if phoenixConfiguration.hasMissingProperty {
            throw ConfigurationError.MissingPropertyError
        }
        
        if !phoenixConfiguration.isValid {
            throw ConfigurationError.InvalidPropertyError
        }
        
        // Create shared objects for modules
        let internalConfiguration = phoenixConfiguration.clone()    // Copy for SDK
        
        // Modules
        identity = IdentityModule(withDelegate: delegateWrapper, network: network, configuration: internalConfiguration, installation: installation)
        analytics = AnalyticsModule(withDelegate: delegateWrapper, network: network, configuration: internalConfiguration, installation: installation)
        location = LocationModule(withDelegate: delegateWrapper, network: network, configuration: internalConfiguration, locationManager: locationManager)
        
        let internalAnalytics = analytics as! AnalyticsModule
        let internalLocation = location as! LocationModule
        
        internalAnalytics.locationProvider = (location as? LocationModuleProvider)
        internalLocation.analytics = analytics
    }
    
    /// (INTERNAL) Initializes the Phoenix entry point with a configuration object.
    /// - parameter delegate:      Object that responds to delegate events.
    /// - parameter configuration: Configuration object to configure instance of Phoenix with, will fail if configured incorrectly.
    /// - parameter oauthProvider:  Object responsible for storing OAuth information.
    /// - throws: **ConfigurationError** if the configuration is invalid.
    /// - returns: New instance of the Phoenix SDK base class.
    internal convenience init(
        withDelegate delegate: PhoenixDelegate,
        configuration phoenixConfiguration: Phoenix.Configuration,
        oauthProvider: PhoenixOAuthProvider) throws
    {
        try self.init(
            withDelegate: delegate,
            delegateWrapper: PhoenixDelegateWrapper(),
            network: nil,
            configuration: phoenixConfiguration,
            oauthProvider: oauthProvider,
            installation: Installation(configuration: phoenixConfiguration.clone(),
            applicationVersion: NSBundle.mainBundle(),
            installationStorage: NSUserDefaults()),
            locationManager: LocationManager())
    }
    
    /// (INTERNAL) Provides a convenience initializer to load the configuration from a JSON file.
    /// - parameter delegate:      Object that responds to delegate events.
    /// - parameter file:          The JSON file name (no extension) of the configuration.
    /// - parameter inBundle:      The NSBundle to use. Defaults to the main bundle.
    /// - parameter oauthProvider:  Object responsible for storing OAuth information.
    /// - throws: **ConfigurationError** if the configuration is invalid or there is a problem reading the file.
    /// - returns: New instance of the Phoenix SDK base class.
    convenience internal init(
        withDelegate delegate: PhoenixDelegate,
        file: String,
        inBundle: NSBundle=NSBundle.mainBundle(),
        oauthProvider: PhoenixOAuthProvider) throws
    {
        try self.init(
            withDelegate: delegate,
            configuration: Configuration.configuration(fromFile: file, inBundle: inBundle),
            oauthProvider: oauthProvider)
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
        let provider = PhoenixOAuthDefaultProvider()
        try self.init(
            withDelegate: delegate,
            file:file,
            inBundle:inBundle,
            oauthProvider: provider)
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
        try self.init(
            withDelegate: delegate,
            file:file,
            inBundle:inBundle,
            oauthProvider: PhoenixOAuthDefaultProvider())
    }
    
    /// Starts up the Phoenix SDK modules.
    /// - parameter callback: Called when the startup of Phoenix finishes. Receives in a boolean 
    /// whether the startup was successful or not. This call has to finish successfully
    /// before using any of the phoenix modules. If any action is performed while startup
    /// has not yet finished fully, an unexpected error is likely to occur.
    public func startup(completion: (success: Bool) -> ()) {
        // Anonymously logins into the SDK then:
        // - Cannot request anything on behalf of the user.
        // - Calls Application Installed/Updated/Opened.
        // - Initialises Geofence load/download.
        // - Startup Events module, send stored events.
        
        func moduleToStartup(module:Int) {
            if module >= modules.count {
                completion(success: true)
                return
            }
            
            modules[module].startup { (success) -> () in
                if ( success ) {
                    moduleToStartup(module + 1)
                }
                else {
                    completion(success: false)
                }
            }
        }
        
        moduleToStartup(0)
    }
    
    /// Shutdowns the Phoenix SDK modules. After shutting down, you'll have to
    /// startup again before being able to use Phoenix reliably again.
    public func shutdown() {
        modules.forEach{
            $0.shutdown()
        }
    }
}