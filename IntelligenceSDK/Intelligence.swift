//
//  Intelligence.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 22/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Mandatory public protocol developers must implement in order to respond to events correctly.

@objc(INTDelegate)
public protocol IntelligenceDelegate {
    /// Credentials provided are incorrect.
    /// Will not distinguish between incorrect client or user credentials.
    func credentialsIncorrect(for intelligence: Intelligence)

    /// Account has been disabled and no longer active.
    /// Credentials are no longer valid.
    func accountDisabled(for intelligence: Intelligence)

    /// Account has failed to authentication multiple times and is now locked.
    /// Requires an administrator to unlock the account.
    func accountLocked(for intelligence: Intelligence)

    /// This error and description is only returned from the Validate endpoint
    /// if providing an invalid or expired token.
    func tokenInvalidOrExpired(for intelligence: Intelligence)

    /// Unable to create SDK user, this may occur if a user with the randomized
    /// credentials already exists (highly unlikely) or your Application is
    /// configured incorrectly and has the wrong permissions.
    func userCreationFailed(for intelligence: Intelligence)

    /// User is required to login again, developer must implement this method
    /// you may present a 'Login Screen' or silently call identity.login with
    /// stored credentials.
    func userLoginRequired(for intelligence: Intelligence)

    /// Unable to assign provided sdk_user_role to your newly created user.
    /// This may occur if the Application is configured incorrectly in the backend
    /// and doesn't have the correct permissions or the role doesn't exist.
    func userRoleAssignmentFailed(for intelligence: Intelligence)
}

/// Wrapping protocol used by modules to pass back errors to Intelligence.

protocol IntelligenceInternalDelegate {
    // Implementation will call credentialsIncorrectForIntelligence
    func credentialsIncorrect()
    // Implementation will call accountDisabledForIntelligence
    func accountDisabled()
    // Implementation will call accountLockedForIntelligence
    func accountLocked()
    // Implementation will call invalidOrExpiredTokenForIntelligence
    func tokenInvalidOrExpired()
    // Implementation will call IntelligenceDelegate.userCreationFailedForIntelligence
    func userCreationFailed()
    // Implementation will call IntelligenceDelegate.userLoginRequiredForIntelligence
    func userLoginRequired()
    // Implementation will call IntelligenceDelegate.userRoleAssignmentFailedForIntelligence
    func userRoleAssignmentFailed()
}

class IntelligenceDelegateWrapper: IntelligenceInternalDelegate {

    var intelligence: Intelligence!
    var delegate: IntelligenceDelegate!

    // MARK: - IntelligenceInternalDelegate

    func credentialsIncorrect() {
        delegate.credentialsIncorrect(for: intelligence)
    }

    func accountDisabled() {
        sharedIntelligenceLogger.logger?.error("Account disabled")
        delegate.accountDisabled(for: intelligence)
    }

    func accountLocked() {
        sharedIntelligenceLogger.logger?.error("Account Locked")
        delegate.accountLocked(for: intelligence)
    }

    func tokenInvalidOrExpired() {
        sharedIntelligenceLogger.logger?.error("Token invalid/Expired")
        delegate.tokenInvalidOrExpired(for: intelligence)
    }

    func userCreationFailed() {
        sharedIntelligenceLogger.logger?.error("SDK User creation failed")
        delegate.userCreationFailed(for: intelligence)
    }

    func userLoginRequired() {
        sharedIntelligenceLogger.logger?.error("User login required")
        delegate.userLoginRequired(for: intelligence)
    }

    func userRoleAssignmentFailed() {
        sharedIntelligenceLogger.logger?.error("User Role assignment failed")
        delegate.userRoleAssignmentFailed(for: intelligence)
    }

}

public let sharedIntelligenceLogger: IntelligenceLogger = IntelligenceLogger(enableLogging: false)

public class IntelligenceLogger: NSObject {

    var logger: XCGLogger?

    public var isLoggingEnabled: Bool

    public var logLevel: XCGLogger.Level = .debug {
         didSet {
            guard let logger = self.logger else {
                return
            }
            logger.outputLevel = logLevel
        }
    }

    public var enableLogging: Bool {

        get {
            guard  let _ = self.logger else {
                return false
            }
            return self.isLoggingEnabled
        }
        set {
            #if DEBUG
                if (self.logger == nil && newValue) {
                    self.logger = XCGLogger.default
                    setupLogger()
                } else if (!newValue) {
                    self.logger = nil
                }
                self.isLoggingEnabled = newValue
            #endif
        }
    }

    init(enableLogging: Bool) {
        self.isLoggingEnabled = false
        super.init()
    }

    public func setupLogger () {

        guard let logger = self.logger else {
            return
        }

        clearOldLogFiles()

        let path = createLogFile(forDate: Date())

        logger.setup(level: .debug,
                     showThreadName: false,
                     showLevel: false,
                     showFileNames: false,
                     showLineNumbers: false,
                     writeToFile: path,
                     fileLevel: .none)

    }
}

/// Base class for initialization of the SDK. Developers must call 'startup' method to start modules.
open class Intelligence: NSObject {

    /// - Returns: A **copy** of the configuration.
    open let configuration: Intelligence.Configuration

    /// Responsible for propogating events back to App.
    var delegateWrapper: IntelligenceDelegateWrapper!

    // MARK: - Modules

    /// The identity module, enables user management in the Intelligence backend.
    @objc public internal(set) var identity: IdentityModuleProtocol!

    /// Analytics instance that can be used for posting Events.
    @objc public internal(set) var analytics: AnalyticsModuleProtocol!

    /// The location module, used to internally manages geofences and user location. Hidden from developers.
    @objc public internal(set) var location: LocationModuleProtocol!

    //Logger methods
    public var IntelligenceLogger: IntelligenceLogger = sharedIntelligenceLogger

    /// Array of modules used for calling startup/shutdown methods easily.
    var modules: [ModuleProtocol] {
        return [identity, location, analytics]
    }

    // MARK: - Initializers

    /// (INTERNAL) Initializes the Intelligence entry point with all objects necessary.
    /// - parameter delegate:      Object that responds to delegate events.
    /// - parameter delegateWrapper: The delegate wrapper so we intercept calls to it.
    /// - parameter network:       Network object, responsible for sending all OAuth requests.
    /// - parameter configuration: Configuration object to configure instance of Intelligence with, will fail if configured incorrectly.
    /// - parameter oauthProvider:  Object responsible for storing OAuth information.
    /// - parameter installation:  Object responsible for reading installation information.
    /// - parameter locationManager: Location manager responsible for handling location updates.
    /// - throws: **ConfigurationError** if the configuration is invalid.
    /// - returns: New instance of the Intelligence SDK base class.
    init(
            withDelegate delegate: IntelligenceDelegate,
            delegateWrapper: IntelligenceDelegateWrapper,
            network: Network? = nil,
            configuration intelligenceConfiguration: Intelligence.Configuration,
            oauthProvider: IntelligenceOAuthProvider,
            installation: Installation,
            locationManager: LocationManager
    ) throws {
        self.configuration = intelligenceConfiguration.clone()
        super.init()

        if (intelligenceConfiguration.region == nil) {
            intelligenceConfiguration.region = Region.singapore
        }

        if (intelligenceConfiguration.environment == nil) {
            intelligenceConfiguration.environment = Environment.production
        }

        delegateWrapper.delegate = delegate
        delegateWrapper.intelligence = self

        let network = network ?? Network(delegate: delegateWrapper, authenticationChallengeDelegate: NetworkAuthenticationChallengeDelegate(configuration: configuration), oauthProvider: oauthProvider)

        if intelligenceConfiguration.hasMissingProperty {
            sharedIntelligenceLogger.logger?.error("Missing Intelligence configration propery")
            throw ConfigurationError.missingPropertyError
        }

        if !intelligenceConfiguration.isValid {
            sharedIntelligenceLogger.logger?.error("Missing Intelligence configration propery")
            throw ConfigurationError.invalidPropertyError
        }

        // Create shared objects for modules
        let internalConfiguration = intelligenceConfiguration.clone()    // Copy for SDK

        // Modules
        identity = IdentityModule(withDelegate: delegateWrapper, network: network, configuration: internalConfiguration, installation: installation)
        analytics = AnalyticsModule(withDelegate: delegateWrapper, network: network, configuration: internalConfiguration, installation: installation)
        location = LocationModule(withDelegate: delegateWrapper, network: network, configuration: internalConfiguration, locationManager: locationManager)

        let internalAnalytics = analytics as! AnalyticsModule
        let internalLocation = location as! LocationModule

        internalAnalytics.locationProvider = (location as? LocationModuleProvider)
        internalLocation.analytics = analytics
    }

    /// (INTERNAL) Initializes the Intelligence entry point with a configuration object.
    /// - parameter delegate:      Object that responds to delegate events.
    /// - parameter configuration: Configuration object to configure instance of Intelligence with, will fail if configured incorrectly.
    /// - parameter oauthProvider:  Object responsible for storing OAuth information.
    /// - throws: **ConfigurationError** if the configuration is invalid.
    /// - returns: New instance of the Intelligence SDK base class.
    internal convenience init(
            withDelegate delegate: IntelligenceDelegate,
            configuration intelligenceConfiguration: Intelligence.Configuration,
            oauthProvider: IntelligenceOAuthProvider) throws {
        try self.init(
                withDelegate: delegate,
                delegateWrapper: IntelligenceDelegateWrapper(),
                network: nil,
                configuration: intelligenceConfiguration,
                oauthProvider: oauthProvider,
                installation: Installation(configuration: intelligenceConfiguration.clone(),
                        applicationVersion: Bundle.main,
                        installationStorage: UserDefaults(),
                        oauthProvider: oauthProvider),
                locationManager: LocationManager())
    }

    /// (INTERNAL) Provides a convenience initializer to load the configuration from a JSON file.
    /// - parameter delegate:      Object that responds to delegate events.
    /// - parameter file:          The JSON file name (no extension) of the configuration.
    /// - parameter inBundle:      The NSBundle to use. Defaults to the main bundle.
    /// - parameter oauthProvider:  Object responsible for storing OAuth information.
    /// - throws: **ConfigurationError** if the configuration is invalid or there is a problem reading the file.
    /// - returns: New instance of the Intelligence SDK base class.
    convenience init(
            withDelegate delegate: IntelligenceDelegate,
            file: String,
            inBundle: Bundle = Bundle.main,
            oauthProvider: IntelligenceOAuthProvider) throws {
        try self.init(
                withDelegate: delegate,
                configuration: Configuration.configuration(fromFile: file, inBundle: inBundle),
                oauthProvider: oauthProvider)
    }

    /// Initializes the Intelligence entry point with a configuration object.
    /// - parameter delegate: The delegate to call for events propagated by Intelligence modules.
    /// - parameter configuration: Instance of the Configuration class, object will be copied to avoid mutability.
    /// - throws: **ConfigurationError** if the configuration is invalid.
    /// - returns: New instance of the Intelligence SDK base class.
    convenience public init(
            withDelegate delegate: IntelligenceDelegate,
            configuration intelligenceConfiguration: Intelligence.Configuration) throws {
        // This let is here to avoid the swift garbage collector from releasing
        // this memory immediately after initialization, and before calling the
        // self.init method. Seems to be a bug in Swift.
        let provider = IntelligenceOAuthDefaultProvider()
        try self.init(
                withDelegate: delegate,
                configuration: intelligenceConfiguration,
                oauthProvider: provider)
        validateConfigration(config: intelligenceConfiguration, oauthProvider: provider)
    }

    /// Initialize Intelligence with a configuration file.
    /// - parameter delegate: The delegate to call for events propagated by Intelligence modules.
    /// - parameter file:     The JSON file name (no extension) of the configuration.
    /// - parameter inBundle: The NSBundle to use. Defaults to the main bundle.
    /// - throws: **ConfigurationError** if the configuration is invalid or there is a problem reading the file.
    /// - returns: New instance of the Intelligence SDK base class.
    @objc convenience public init(
            withDelegate delegate: IntelligenceDelegate,
            file: String,
            inBundle: Bundle = Bundle.main) throws {
        // This let is here to avoid the swift garbage collector from releasing
        // this memory immediately after initialization, and before calling the
        // self.init method. Seems to be a bug in Swift.
        let provider = IntelligenceOAuthDefaultProvider()
        try self.init(
                withDelegate: delegate,
                file: file,
                inBundle: inBundle,
                oauthProvider: provider)
        validateConfigration(config: self.configuration, oauthProvider: provider)
    }

    /// Starts up the Intelligence SDK modules.
    /// - parameter callback: Called when the startup of Intelligence finishes. Receives in a boolean 
    /// whether the startup was successful or not. This call has to finish successfully
    /// before using any of the intelligence modules. If any action is performed while startup
    /// has not yet finished fully, an unexpected error is likely to occur.
    @objc(startup:)
    public func startup(completion: @escaping (_ success: Bool) -> Void) {
        // Anonymously logins into the SDK then:
        // - Cannot request anything on behalf of the user.
        // - Calls Application Installed/Updated/Opened.
        // - Initialises Geofence load/download.
        // - Startup Events module, send stored events.

        func moduleToStartup(module: Int) {
            if module >= modules.count {
                completion(true)
                return
            }

            modules[module].startup { (success) -> Void in
                if (success) {
                    moduleToStartup(module: module + 1)
                } else {
                    completion(false)
                }
            }
        }

        moduleToStartup(module: 0)
    }

    private func instantiateLoging() {

    }

    //If there is a change in configuration.This method will reset all the token from the keychain.
    private func validateConfigration(config: Intelligence.Configuration, oauthProvider: IntelligenceOAuthDefaultProvider) {

        func clearAllData() {

            var keyChain = IntelligenceKeychain(account: IntelligenceOAuthTokenType.application.rawValue)
            keyChain.clearAllData()

            keyChain = IntelligenceKeychain(account: IntelligenceOAuthTokenType.loggedInUser.rawValue)
            keyChain.clearAllData()

            IntelligenceOAuth.reset(oauth: &oauthProvider.applicationOAuth)
            IntelligenceOAuth.reset(oauth: &oauthProvider.loggedInUserOAuth)
        }

        guard  let configData = UserDefaults.standard.object(forKey: "IntelligenceConfiguations") as? Data else {
            guard  let data = config.getJsonData() else {
                return
            }
            //Cases like,user deleted the app and install it back. Since data from 
            //Keychain nor get cleared.
            clearAllData()

            UserDefaults.standard.set(data, forKey: "IntelligenceConfiguations")
            UserDefaults.standard.synchronize()
            return
        }

        //read data from use default
        if let configuration = try? Configuration.init(fromData: configData) {
            if (!(config == configuration)) {

                clearAllData()

                if let data = config.getJsonData() {
                    UserDefaults.standard.set(data, forKey: "IntelligenceConfiguations")
                    UserDefaults.standard.synchronize()
                }
            }
        }
    }

    /// Shutdowns the Intelligence SDK modules. After shutting down, you'll have to
    /// startup again before being able to use Intelligence reliably again.
    @objc (shutdown)
    public func shutdown() {
        modules.forEach {
            $0.shutdown()
        }
    }
}
