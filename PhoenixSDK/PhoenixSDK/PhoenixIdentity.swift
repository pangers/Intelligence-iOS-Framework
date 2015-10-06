//
//  PhoenixIdentity.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

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
    func login(withUsername username: String, password: String, callback: PhoenixUserCallback)
    
    /// Logging out will no longer associate events with the authenticated user.
    func logout()
    
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
            withDelegate delegate: PhoenixInternalDelegate,
            network: Network,
            configuration:Configuration,
            installation: Installation)
        {
            super.init(withDelegate: delegate, network: network, configuration: configuration)
            self.installation = installation
        }
        
        private func createSDKUserIfRequired(successBlock: () -> ()) {
            var oauth = network.oauthProvider.sdkUserOAuth
            if oauth.username == nil || oauth.password == nil {
                // Need to create user first.
                let sdkUser = Phoenix.User(companyId: configuration.companyId)
                createUser(sdkUser, callback: { [weak sdkUser, weak self] (serverUser, error) -> Void in
                    // Note: Assign role will call delegate method if it fails because the Phoenix Intelligence
                    // backend may be configured incorrectly.
                    // This callback will NOT be called if that happens because the error is unrecoverable.
                    guard let sdkUser = sdkUser else { return }
                    if serverUser != nil {
                        // Store credentials in keychain.
                        oauth.updateCredentials(withUsername: sdkUser.username, password: sdkUser.password!)
                        oauth.userId = serverUser?.userId
                        // If we have a user, need to call get pipeline again.
                        successBlock()
                    } else {
                        // Pass error back to developer (special case, use delegate).
                        // Probably means that user already exists, or perhaps Application is configured incorrectly
                        // and cannot create users.
                        self?.delegate?.userCreationFailed()
                    }
                })
            } else {
                successBlock()
            }
        }
        
        override func startup(completion: (success: Bool) -> ()) {
            super.startup { [weak network, weak configuration] (success) -> () in
                if !success {
                    completion(success: false)
                    return
                }
                guard let network = network, configuration = configuration else {
                    completion(success: false)
                    return
                }
                
                // Get pipeline for grant_type 'client_credentials'.
                network.getPipeline(forOAuth: network.oauthProvider.applicationOAuth, configuration: configuration) { [weak self] (applicationPipeline) -> () in
                    guard let applicationPipeline = applicationPipeline, identity = self else {
                        // Shouldn't happen.
                        assertionFailure("Startup shouldn't be called multiple times")
                        return
                    }
                    identity.network.enqueueOperation(applicationPipeline)
                    
                    // Once complete, lets login/create our SDK User.
                    applicationPipeline.completionBlock = {
                        // Create user if their credentials are empty.
                        identity.createSDKUserIfRequired({ () -> () in
                            // Get pipeline if created or existing.
                            identity.network.getPipeline(forOAuth: identity.network.oauthProvider.sdkUserOAuth, configuration: identity.configuration, completion: { [weak self] (sdkUserPipeline) -> () in
                                guard let identity = self, sdkUserPipeline = sdkUserPipeline else {
                                    // Should not happen (user created above)
                                    completion(success: false)
                                    return
                                }
                                
                                identity.network.enqueueOperation(sdkUserPipeline)
                                sdkUserPipeline.completionBlock = { [weak self] in
                                    guard let identity = self else {
                                        completion(success: false)
                                        return
                                    }
                                    // Installation can succeed without a user id
                                    identity.createInstallation(nil)
                                    identity.updateInstallation(nil)
                                    // Grab our user ID.
                                    identity.getMe(identity.network.oauthProvider.sdkUserOAuth, callback: { [weak identity] (user, error) -> Void in
                                        // Update user id for SDKUser
                                        identity?.network.oauthProvider.sdkUserOAuth.userId = user?.userId
                                        completion(success: error == nil)
                                    })
                                }
                            })
                        })
                    }
                }
            }
        }
        
        override func shutdown() {
            // Nothing to do currently.
            super.shutdown()
        }
        
        // MARK:- Login
        
        @objc func login(withUsername username: String, password: String, callback: PhoenixUserCallback) {
            let oauth = network.oauthProvider.loggedInUserOAuth
            oauth.updateCredentials(withUsername: username, password: password)
            
            network.oauthProvider.developerLoggedIn = false
            
            let pipeline = PhoenixOAuthPipeline(withOperations: [PhoenixOAuthValidateOperation(), PhoenixOAuthRefreshOperation(), PhoenixOAuthLoginOperation()], oauth: oauth, configuration: configuration, network: network)
            
            pipeline.completionBlock = { [weak pipeline, weak self] in
                // Clear password from memory.
                if (pipeline?.oauth?.tokenType == .LoggedInUser) {
                    pipeline?.oauth?.password = nil
                }
                
                if pipeline?.output?.error != nil {
                    // Failed, tell developer!
                    callback(user: nil, error: NSError(domain: IdentityError.domain, code: IdentityError.LoginFailed.rawValue, userInfo: nil))
                } else {
                    // Get user me.
                    self?.getMe({ [weak self] (user, error) -> Void in
                        // Clear userid if get me fails, otherwise update user id.
                        pipeline?.oauth?.userId = user?.userId
                    
                        // Logged in only if we have a user.
                        self?.network.oauthProvider.developerLoggedIn = user?.userId != nil
                        
                        // Notify developer
                        callback(user: user, error: error)
                    })
                }
            }
            
            network.enqueueOperation(pipeline)
        }
        
        @objc func logout() {
            network.oauthProvider.developerLoggedIn = false
            PhoenixOAuth.reset(network.oauthProvider.loggedInUserOAuth)
        }
        
        
        // MARK: - User Management
        
        @objc func updateUser(user: Phoenix.User, callback: PhoenixUserCallback? = nil) {
            if !user.isValidToUpdate {
                callback?(user:nil, error: NSError(domain:IdentityError.domain, code: IdentityError.InvalidUserError.rawValue, userInfo: nil) )
                return
            }
            
            if !user.isPasswordSecure() {
                callback?(user:nil, error: NSError(domain:IdentityError.domain, code: IdentityError.WeakPasswordError.rawValue, userInfo: nil) )
                return
            }
            
            let operation = UpdateUserRequestOperation(user: user, oauth: network.oauthProvider.loggedInUserOAuth, configuration: configuration, network: network)
            operation.completionBlock = { [weak operation] in
                callback?(user: operation?.user, error: operation?.output?.error)
            }
            
            // Execute the network operation
            network.enqueueOperation(operation)
        }
        
        internal func getMe(oauth: PhoenixOAuthProtocol, callback: PhoenixUserCallback) {
            let operation = GetUserMeRequestOperation(oauth: oauth, configuration: configuration, network: network)
            operation.completionBlock = { [weak operation] in
                callback(user: operation?.user, error: operation?.output?.error)
            }
            
            // Execute the network operation
            network.enqueueOperation(operation)
        }
        
        @objc func getMe(callback: PhoenixUserCallback) {
            getMe(network.oauthProvider.loggedInUserOAuth, callback: callback)
        }
        
        // MARK: Internal
        
        /// Registers a user in the backend.
        /// - Parameters:
        ///     - user: Phoenix User instance containing information about the user we are trying to create.
        ///     - callback: The user callback to pass. Will be called with either an error or a user.
        /// The developer is responsible to dispatch the callback to the main thread using dispatch_async if necessary.
        /// - Throws: Returns an NSError in the callback using as code IdentityError.InvalidUserError when the
        /// user is invalid, and IdentityError.UserCreationError when there is an error while creating it.
        /// The NSError domain is IdentityError.domain
        internal func createUser(user: Phoenix.User, callback: PhoenixUserCallback? = nil) {
            if !user.isValidToCreate {
                callback?(user:nil, error: NSError(domain:IdentityError.domain, code: IdentityError.InvalidUserError.rawValue, userInfo: nil) )
                return
            }
            
            if !user.isPasswordSecure() {
                callback?(user:nil, error: NSError(domain:IdentityError.domain, code: IdentityError.WeakPasswordError.rawValue, userInfo: nil) )
                return
            }
            
            // Create user operation.
            let operation = CreateUserRequestOperation(user: user, oauth: network.oauthProvider.applicationOAuth, configuration: configuration, network: network)
            operation.completionBlock = { [weak operation] in
                if operation?.output?.error == nil && operation?.user != nil {
                    // On successful operation, lets assign users role.
                    // Assert that all variables exist on the operation as they have been asserted on creation of the operation itself.
                    let assignOperation = AssignUserRoleRequestOperation(user: operation!.user, oauth: operation!.oauth!, configuration: operation!.configuration!, network: operation!.network!)
                    assignOperation.completionBlock = { [weak assignOperation, weak self] in
                        // Execute original callback.
                        // If assign role fails, the user will exist but not have any access, there is nothing we can do
                        // if the developer is trying to assign a role that doesn't exist or the server changes in some
                        // unexpected way. We don't receive a unique error code, so just call the delegate on any error.
                        if assignOperation?.output?.error != nil {
                            self?.delegate.userRoleAssignmentFailed()
                        } else {
                            callback?(user: assignOperation?.user, error: assignOperation?.output?.error)
                        }
                    }
                    operation!.network!.enqueueOperation(assignOperation)
                } else {
                    // On failure, simply execute callback.
                    callback?(user: operation?.user, error: operation?.output?.error)
                }
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
            
            let operation = CreateInstallationRequestOperation(installation: installation, oauth: network.oauthProvider.bestPasswordGrantOAuth, configuration: configuration, network: network)
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
            let operation = UpdateInstallationRequestOperation(installation: installation, oauth: network.oauthProvider.bestPasswordGrantOAuth, configuration: configuration, network: network)
            operation.completionBlock = { [weak operation, weak self] in
                callback?(installation: self?.installation, error: operation?.output?.error)
            }
            
            // Execute the network operation
            network.enqueueOperation(operation)
        }
    }
}