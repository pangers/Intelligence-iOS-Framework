//
//  PhoenixIdentity.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// Valid login if error is nil.
public typealias PhoenixLoginCallback = (error: NSError?) -> ()

/// A generic PhoenixUserCallback in which we get either a PhoenixUser or an error.
public typealias PhoenixUserCallback = (user:Phoenix.User?, error:NSError?) -> Void

/// Called on completion of update or create installation request.
/// - Returns: Installation object and optional error.
internal typealias PhoenixInstallationCallback = (installation: Phoenix.Installation?, error: NSError?) -> Void

/// The Phoenix Idenity module protocol. Defines the available API calls that can be performed.
@objc public protocol PhoenixIdentity : PhoenixModuleProtocol {
    
    /// Attempt to authenticate with a username and password.
    /// Logging in with associate events with this user.
    /// - Parameters
    ///     - username: Username of account to attempt login with.
    ///     - password: Password associated with username.
    ///     - callback: The user callback to pass. Will be called with either an error or a user.
    func login(withUsername username: String, password: String, callback: PhoenixLoginCallback)
    
    /// Logging out will no longer associate events with the authenticated user.
    func logout()
    
    /// Registers a user in the backend.
    /// - Parameters:
    ///     - user: Phoenix User instance containing information about the user we are trying to create.
    ///     - callback: The user callback to pass. Will be called with either an error or a user.
    /// The queue on which the callback is called is not guaranteed. It might or might not be the main thread.
    /// The developer is responsible to dispatch it to the main thread using dispatch_async to avoid deadlocks.
    /// - Throws: Returns an NSError in the callback using as code IdentityError.InvalidUserError when the
    /// user is invalid, and IdentityError.UserCreationError when there is an error while creating it.
    /// The NSError domain is IdentityError.domain
    func createUser(user:Phoenix.User, callback:PhoenixUserCallback?)
    
    /// Updates a user in the backend.
    /// - Parameters:
    ///     - user: Phoenix User instance containing information about the user we are trying to update.
    ///     - callback: Will be called with either an error or a user.
    func updateUser(user:Phoenix.User, callback:PhoenixUserCallback?)
    
    /// Get details about logged in user.
    /// - parameter callback: Will be called with either an error or a user.
    func getMe(callback:PhoenixUserCallback)
}

extension Phoenix {
    
    /// The PhoenixIdentity implementation.
    final class Identity : PhoenixModule, PhoenixIdentity {

        /// Installation object used for Create/Update Installation requests.
        private var installation: Phoenix.Installation!
        
        init(
            withNetwork network: Network,
            configuration:Configuration,
            installation: Installation)
        {
            super.init(withNetwork: network, configuration: configuration)
            self.installation = installation
        }
        
        override func startup() {
            super.startup()
            network.getPipeline(forTokenType: .Application, configuration: configuration) { [weak self] (applicationPipeline) -> () in
                guard let applicationPipeline = applicationPipeline, identity = self else {
                    // Shouldn't happen.
                    assertionFailure("Startup shouldn't be called multiple times")
                    return
                }
                identity.network.enqueueOperation(applicationPipeline)
                identity.network.getPipeline(forTokenType: .SDKUser, configuration: identity.configuration, completion: { [weak self] (sdkUserPipeline) -> () in
                    guard let sdkUserPipeline = sdkUserPipeline, identity = self else {
                        // Create user needs to occur.
                        return
                    }
                    // TODO: Create user if their credentials are empty.
                    identity.network.enqueueOperation(sdkUserPipeline)
                    sdkUserPipeline.completionBlock = { [weak self] in
                        self?.createInstallation(nil)
                        self?.updateInstallation(nil)
                    }
                })
            }
        }
        
        override func shutdown() {
            // Nothing to do currently.
            super.shutdown()
        }
        
        // MARK:- Login
        
        @objc func login(withUsername username: String, password: String, callback: PhoenixLoginCallback) {
            let oauth = PhoenixOAuth(tokenType: .LoggedInUser)
            oauth.updateCredentials(withUsername: username, password: password)
            
            network.developerLoggedIn = false
            
            let pipeline = PhoenixOAuthPipeline(withOperations: [PhoenixOAuthValidateOperation(), PhoenixOAuthRefreshOperation(), PhoenixOAuthLoginOperation()], oauth: oauth, configuration: configuration, network: network)
            
            pipeline.completionBlock = { [weak pipeline, weak self] in
                if pipeline?.output?.error != nil {
                    callback(error: NSError(domain: IdentityError.domain, code: IdentityError.LoginFailed.rawValue, userInfo: nil))
                } else {
                    self?.network.developerLoggedIn = true
                    // Clear password from memory.
                    if (pipeline?.oauth?.tokenType == .LoggedInUser) {
                        pipeline?.oauth?.password = nil
                    }
                    callback(error: nil)
                }
            }
            
            network.enqueueOperation(pipeline)
        }
        
        @objc func logout() {
            network.developerLoggedIn = false
            PhoenixOAuth.reset(.LoggedInUser)
        }
        
        
        // MARK: - User Management
        
        @objc func createUser(user: Phoenix.User, callback: PhoenixUserCallback? = nil) {
            if !user.isValidToCreate {
                callback?(user:nil, error: NSError(domain:IdentityError.domain, code: IdentityError.InvalidUserError.rawValue, userInfo: nil) )
                return
            }
            
            if !user.isPasswordSecure() {
                callback?(user:nil, error: NSError(domain:IdentityError.domain, code: IdentityError.WeakPasswordError.rawValue, userInfo: nil) )
                return
            }
            
            let operation = CreateUserRequestOperation(user: user, configuration: configuration, network: network)
            operation.completionBlock = { [weak operation] in
                callback?(user: operation?.user, error: operation?.output?.error)
            }
            
            // Execute the network operation
            network.enqueueOperation(operation)
        }
        
        @objc func updateUser(user: Phoenix.User, callback: PhoenixUserCallback? = nil) {
            if !user.isValidToUpdate {
                callback?(user:nil, error: NSError(domain:IdentityError.domain, code: IdentityError.InvalidUserError.rawValue, userInfo: nil) )
                return
            }
            
            if !user.isPasswordSecure() {
                callback?(user:nil, error: NSError(domain:IdentityError.domain, code: IdentityError.WeakPasswordError.rawValue, userInfo: nil) )
                return
            }
            
            let operation = UpdateUserRequestOperation(user: user, configuration: configuration, network: network)
            operation.completionBlock = { [weak operation] in
                callback?(user: operation?.user, error: operation?.output?.error)
            }
            
            // Execute the network operation
            network.enqueueOperation(operation)
        }
        
        // MARK: Private
        
        /// Gets a user data from the current user credentials.
        /// - Parameters:
        ///     - disposableLoginToken: Only used by 'getUserMe' and is the access_token we receive from the 'login' and is discarded immediately after this call.
        ///     - callback: The user callback to pass. Will be called with either an error or a user.
        @objc func getMe(callback: PhoenixUserCallback) {
            let operation = GetUserMeRequestOperation(configuration: configuration, network: network)
            operation.completionBlock = { [weak operation] in
                callback(user: operation?.user, error: operation?.output?.error)
            }
            
            // Execute the network operation
            network.enqueueOperation(operation)
        }
        
        // MARK:- Installation
        
        /// Schedules a create installation request if first install.
        /// - Parameters:
        ///     - installation: Optional installation object to use instead of self.installation.
        ///     - callback: Optionally provide a callback to fire on completion.
        internal func createInstallation(callback: PhoenixInstallationCallback? = nil) {
            if !installation.isNewInstallation {
                callback?(installation: installation, error: NSError(domain: InstallationError.domain, code: InstallationError.AlreadyInstalledError.rawValue, userInfo: nil))
                return
            }
            
            let operation = CreateInstallationRequestOperation(installation: installation, configuration: configuration, network: network)
            operation.completionBlock = { [weak operation, weak self] in
                callback?(installation: self?.installation, error: operation?.output?.error)
            }
            
            // Execute the network operation
            network.enqueueOperation(operation)
        }
        
        /// Schedules an update installation request if version number changed.
        /// - Parameters:
        ///     - callback: Optionally provide a callback to fire on completion.
        internal func updateInstallation(callback: PhoenixInstallationCallback? = nil) {
            if !installation.isUpdatedInstallation {
                callback?(installation: installation, error: NSError(domain: InstallationError.domain, code: InstallationError.AlreadyUpdatedError.rawValue, userInfo: nil))
                return
            }
            
            // If this call fails, it will retry again the next time we open the app.
            let operation = UpdateInstallationRequestOperation(installation: installation, configuration: configuration, network: network)
            operation.completionBlock = { [weak operation, weak self] in
                callback?(installation: self?.installation, error: operation?.output?.error)
            }
            
            // Execute the network operation
            network.enqueueOperation(operation)
        }
    }
}