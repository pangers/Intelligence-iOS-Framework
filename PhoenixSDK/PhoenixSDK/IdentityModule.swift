//
//  IdentityModule.swift
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
internal typealias PhoenixInstallationCallback = (installation: PhoenixInstallation?, error: NSError?) -> Void

/// The Phoenix Idenity module protocol. Defines the available API calls that can be performed.
@objc public protocol IdentityModuleProtocol : ModuleProtocol {
    
    /// Attempt to authenticate with a username and password.
    /// Logging in with associate events with this user.
    /// - Parameters
    ///     - username: Username of account to attempt login with.
    ///     - password: Password associated with username.
    ///     - callback: The user callback to pass. Will be called with either an error or a user.
    func login(withUsername username: String, password: String, callback: PhoenixUserCallback)
    
    /// Logging out will no longer associate events with the authenticated user.
    func logout()
    
    /// Get details about logged in user.
    /// - parameter callback: Will be called with either an error or a user.
    func getMe(callback: PhoenixUserCallback)
    
    /// Updates a user in the backend.
    /// - Parameters:
    ///     - user: Phoenix User instance containing information about the user we are trying to update.
    ///     - callback: Will be called with either an error or a user.
    func updateUser(user: Phoenix.User, callback: PhoenixUserCallback)
}

/// The IdentityModule implementation.
final class IdentityModule : PhoenixModule, IdentityModuleProtocol {
    
    /// Installation object used for Create/Update Installation requests.
    private var installation: PhoenixInstallation!
    
    init(
        withDelegate delegate: PhoenixInternalDelegate,
        network: Network,
        configuration: Phoenix.Configuration,
        installation: PhoenixInstallation)
    {
        super.init(withDelegate: delegate, network: network, configuration: configuration)
        self.installation = installation
    }
    
    private func createSDKUserIfRequired(successBlock: () -> ()) {
        var oauth = network.oauthProvider.sdkUserOAuth
        if oauth.username == nil || oauth.password == nil {
            // Need to create user first.
            let sdkUser = Phoenix.User(companyId: configuration.companyId)
            let password = sdkUser.password
            createUser(sdkUser, callback: { [weak self] (serverUser, error) -> Void in
                if serverUser != nil {
                    // Store credentials in keychain.
                    oauth.updateCredentials(withUsername: serverUser!.username, password: password!)
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
                
                applicationPipeline.callback = { (returnedOperation: PhoenixOAuthOperation) -> () in
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
                            
                            sdkUserPipeline.callback = { [weak self] (returnedOperation: PhoenixOAuthOperation) -> () in
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
        var oauth = network.oauthProvider.loggedInUserOAuth
        oauth.updateCredentials(withUsername: username, password: password)
        
        network.oauthProvider.developerLoggedIn = false
        
        let pipeline = PhoenixOAuthPipeline(withOperations: [PhoenixOAuthValidateOperation(), PhoenixOAuthRefreshOperation(), PhoenixOAuthLoginOperation()], oauth: oauth, configuration: configuration, network: network)
        
        pipeline.callback = { [weak self] (returnedOperation: PhoenixOAuthOperation) -> () in
            guard let returnedPipeline = returnedOperation as? PhoenixOAuthPipeline else {
                assertionFailure("Invalid operation returned")
                return
            }
            
            // Clear password from memory.
            if oauth.tokenType == .LoggedInUser {
                oauth.password = nil
            }
            
            if returnedPipeline.output?.error != nil {
                // Failed, tell developer!
                guard let domain = returnedPipeline.output?.error?.domain where domain == IdentityError.domain || domain == RequestError.domain else {
                    // Wrap again
                    callback(user: nil, error: NSError(domain: IdentityError.domain, code: IdentityError.LoginFailed.rawValue, userInfo: nil))
                    return
                }
                callback(user: nil, error: returnedPipeline.output?.error)
            } else {
                // Get user me.
                self?.getMe({ (user, error) -> Void in
                    // Clear userid if get me fails, otherwise update user id.
                    oauth.userId = user?.userId
                    
                    // Logged in only if we have a user.
                    self?.network.oauthProvider.developerLoggedIn = oauth.userId != nil
                    
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
    
    @objc func updateUser(user: Phoenix.User, callback: PhoenixUserCallback) {
        if !user.isValidToUpdate {
            callback(user:nil, error: NSError(domain:IdentityError.domain, code: IdentityError.InvalidUserError.rawValue, userInfo: nil) )
            return
        }
        
        if !user.isPasswordSecure() {
            callback(user:nil, error: NSError(domain:IdentityError.domain, code: IdentityError.WeakPasswordError.rawValue, userInfo: nil) )
            return
        }
        
        let operation = UpdateUserRequestOperation(user: user, oauth: network.oauthProvider.loggedInUserOAuth,
            configuration: configuration, network: network, callback: { (returnedOperation: PhoenixOAuthOperation) -> () in
                if let updateOperation = returnedOperation as? UpdateUserRequestOperation {
                    callback(user: updateOperation.user, error: updateOperation.output?.error)
                } else {
                    assertionFailure("Invalid operation returned")
                }
        })
        
        // Execute the network operation
        network.enqueueOperation(operation)
    }
    
    internal func getMe(oauth: PhoenixOAuthProtocol, callback: PhoenixUserCallback) {
        let operation = GetUserMeRequestOperation(oauth: oauth, configuration: configuration, network: network, callback: { (returnedOperation: PhoenixOAuthOperation) -> () in
            if let getMeOperation = returnedOperation as? GetUserMeRequestOperation {
                callback(user: getMeOperation.user, error: getMeOperation.output?.error)
            } else {
                assertionFailure("Invalid operation returned")
            }
        })
        
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
        let operation = CreateUserRequestOperation(user: user, oauth: network.oauthProvider.applicationOAuth, configuration: configuration, network: network, callback: { (returnedOperation: PhoenixOAuthOperation) -> () in
            guard let createUserOperation = returnedOperation as? CreateUserRequestOperation else {
                assertionFailure("Invalid operation returned")
                return
            }
            if createUserOperation.output?.error == nil && createUserOperation.user != nil {
                // On successful operation, lets assign users role.
                // Assert that all variables exist on the operation as they have been asserted on creation of the operation itself.
                let assignOperation = AssignUserRoleRequestOperation(user: createUserOperation.user, oauth: createUserOperation.oauth!, configuration: createUserOperation.configuration!, network: createUserOperation.network!, callback: { [weak self] (returnedOperation: PhoenixOAuthOperation) -> () in
                    guard let assignRoleOperation = returnedOperation as? AssignUserRoleRequestOperation else {
                        assertionFailure("Invalid operation returned")
                        return
                    }
                    // Execute original callback.
                    // If assign role fails, the user will exist but not have any access, there is nothing we can do
                    // if the developer is trying to assign a role that doesn't exist or the server changes in some
                    // unexpected way.
                    if assignRoleOperation.output?.error != nil {
                        // Note: Assign role will also call a delegate method if it fails because the Phoenix Intelligence
                        // backend may be configured incorrectly.
                        // We don't receive a unique error code, so just call the delegate on any error.
                        self?.delegate.userRoleAssignmentFailed()
                        // Also call callback, so developer doesn't get stuck waiting for a response.
                        callback?(user: nil, error: assignRoleOperation.output?.error)
                    } else {
                        callback?(user: assignRoleOperation.user, error: assignRoleOperation.output?.error)
                    }
                    })
                createUserOperation.network!.enqueueOperation(assignOperation)
            } else {
                // On failure, simply execute callback.
                callback?(user: createUserOperation.user, error: createUserOperation.output?.error)
            }
        })
        
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
        
        let operation = CreateInstallationRequestOperation(installation: installation, oauth: network.oauthProvider.bestPasswordGrantOAuth, configuration: configuration, network: network, callback: { (returnedOperation: PhoenixOAuthOperation) -> () in
            if let createInstallationOperation = returnedOperation as? CreateInstallationRequestOperation {
                callback?(installation: createInstallationOperation.installation, error: createInstallationOperation.output?.error)
            } else {
                assertionFailure("Invalid operation returned")
            }
        })
        
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
        let operation = UpdateInstallationRequestOperation(installation: installation, oauth: network.oauthProvider.bestPasswordGrantOAuth, configuration: configuration, network: network, callback: { (returnedOperation: PhoenixOAuthOperation) -> () in
            if let updateInstallationOperation = returnedOperation as? UpdateInstallationRequestOperation {
                callback?(installation: updateInstallationOperation.installation, error: updateInstallationOperation.output?.error)
            } else {
                assertionFailure("Invalid operation returned")
            }
        })
        
        // Execute the network operation
        network.enqueueOperation(operation)
    }
}