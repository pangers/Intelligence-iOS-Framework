//
//  IdentityModule.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// A generic UserCallback in which we get either an IntelligenceUser or an error.
public typealias UserCallback = (user:Intelligence.User?, error:NSError?) -> Void

/// Called on completion of update or create installation request.
/// - Returns: Installation object and optional error.
internal typealias InstallationCallback = (installation: Installation?, error: NSError?) -> Void

/// Callback for Register Device Token method, developer is responsbile for managing the tokenId and calling unregister at appropriate times.
public typealias RegisterDeviceTokenCallback = (tokenId: Int, error: NSError?) -> Void
/// Callback for Unregister Device Token method, an error may occur if tokenId was not registred or is registered against another user.
public typealias UnregisterDeviceTokenCallback = (error: NSError?) -> Void
/// Callback for Unregister Device Token (On Befalf) method
public typealias UnregisterDeviceTokenOnBehalfCallback = (error: NSError?) -> Void

private let InvalidDeviceTokenID = -1
private let CreateSDKUserRetries = 5

/// The Intelligence Idenity module protocol. Defines the available API calls that can be performed.
@objc(INTIdentityModuleProtocol)
public protocol IdentityModuleProtocol : ModuleProtocol {
    
    /// Attempt to authenticate with a username and password.
    /// Logging in with associate events with this user.
    /// - Parameters
    ///     - username: Username of account to attempt login with.
    ///     - password: Password associated with username.
    ///     - callback: The user callback to pass. Will be called with either an error or a user.
    func login(withUsername username: String, password: String, callback: UserCallback)
    
    /// Logging out will no longer associate events with the authenticated user.
    func logout()

    /// Get details about a user.
    /// - parameter userId: The id of the user to retrieve details for.
    /// - parameter callback: Will be called with either an error or a user.
    func getUser(userId: Int, callback: UserCallback)
    
    /// Assign a role to a user.
    /// - parameter roleId: The id of the role to assign.
    /// - parameter user: The user to assign the role to.
    /// - parameter callback: Will be called with either an error or a user.
    func assignRole(roleId: Int, user: Intelligence.User, callback: UserCallback)
    
    /// Revoke a role from a user.
    /// - parameter roleId: The id of the role to revoke.
    /// - parameter user: The user to revoke the role from.
    /// - parameter callback: Will be called with either an error or a user.
    func revokeRole(roleId: Int, user: Intelligence.User, callback: UserCallback)
    
    /// Get details about logged in user.
    /// - parameter callback: Will be called with either an error or a user.
    func getMe(callback: UserCallback)
    
    /// Updates a user in the backend.
    /// - Parameters:
    ///     - user: Intelligence User instance containing information about the user we are trying to update.
    ///     - callback: Will be called with either an error or a user.
    func updateUser(user: Intelligence.User, callback: UserCallback)
    
    /// Register a push notification token on the Intelligence platform.
    /// - parameter data: Data received from 'application:didRegisterForRemoteNotificationsWithDeviceToken:' response.
    /// - parameter callback: Callback to fire on completion, will contain error or token ID. Developer should store token ID and is responsible for managing the flow of registration for push.
    func registerDeviceToken(data: NSData, callback: RegisterDeviceTokenCallback)
    
    /// Unregister a token ID in the backend, will fail if it was registered against another user.
    /// - parameter tokenId: Previously registered token ID. Should be unregistered prior to logout if you have multiple accounts.
    /// - parameter callback: Callback to fire on completion, error will be set if unable to unregister.
    func unregisterDeviceToken(withId tokenId: Int, callback: UnregisterDeviceTokenCallback)
}

/// The IdentityModule implementation.
final class IdentityModule : IntelligenceModule, IdentityModuleProtocol {
    
    /// Installation object used for Create/Update Installation requests.
    private var installation: Installation!
    
    init(
        withDelegate delegate: IntelligenceInternalDelegate,
        network: Network,
        configuration: Intelligence.Configuration,
        installation: Installation)
    {
        super.init(withDelegate: delegate, network: network, configuration: configuration)
        self.installation = installation
    }
    
    private func createSDKUserIfRequired(completion: (Bool) -> ()) {
        var oauth = network.oauthProvider.sdkUserOAuth
        if oauth.username != nil && oauth.password != nil {
                completion(true)
                return
        }
        
        // Need to create user first.
        let sdkUser = Intelligence.User(companyId: configuration.companyId)
        let password = sdkUser.password
        
        createUser(sdkUser) { [weak self] (serverUser, error) -> Void in
            // defer the completion callback call.
            defer {
                completion(serverUser != nil)
            }
            
            if serverUser != nil {
                // Store credentials in keychain.
                oauth.updateCredentials(withUsername: serverUser!.username, password: password!)
                oauth.userId = serverUser?.userId
            }
        }
    }
    
    /**
    Creates an SDK user doing "counter" retries.
    
    It creates the user only if required, and makes sure to generate the OAuth calls
    required to login using Network.getPipeline.
    
    - parameter counter:    The number of retries to perform.
    - parameter completion: A callback to notify on success or failure.
    */
    private func createSDKUserRecursively(counter: Int, completion: (success: Bool) -> ()) {
        if counter <= 1 {
            
            // Pass error back to developer (special case, use delegate).
            // Probably means that user already exists, or perhaps Application is configured incorrectly
            // and cannot create users.
            self.delegate?.userCreationFailed()
            
            completion(success: false)
            return
        }
        
        // Create user if their credentials are empty.
        self.createSDKUserIfRequired({ [weak self] (success: Bool) -> () in
            guard let identity = self else {
                completion(success: false)
                return
            }
            
            if !success {
                identity.createSDKUserRecursively(counter - 1, completion: completion)
                return
            }
            
            // Get pipeline if created or existing.
            identity.network.getPipeline(forOAuth: identity.network.oauthProvider.sdkUserOAuth, configuration: identity.configuration) { [weak self] (sdkUserPipeline) -> () in
                    
                    guard let identity = self, sdkUserPipeline = sdkUserPipeline else {
                        // Should not happen (user created above)
                        completion(success: false)
                        return
                    }
                    
                    identity.network.enqueueOperation(sdkUserPipeline)
                    
                    sdkUserPipeline.callback = { [weak self] (returnedOperation: IntelligenceAPIOperation) -> () in
                        guard let identity = self else {
                            completion(success: false)
                            return
                        }
                        
                        if let error = returnedOperation.output?.error {
                            switch error.code {
                                case AuthenticationError.CredentialError.rawValue,
                                AuthenticationError.AccountDisabledError.rawValue,
                                AuthenticationError.AccountLockedError.rawValue,
                                AuthenticationError.TokenInvalidOrExpired.rawValue:
                                    IntelligenceOAuth.reset(identity.network.oauthProvider.sdkUserOAuth)
                                    identity.createSDKUserRecursively(counter - 1, completion: completion)
                                default:
                                    completion(success: false)
                            }
                            
                            return
                        }
                    
                        // Installation can succeed without a user id
                        identity.createInstallation(nil)
                        identity.updateInstallation(nil)
                        
                        // Grab our user ID.
                        identity.getMe(identity.network.oauthProvider.sdkUserOAuth) { [weak identity] (user, error) -> Void in
                            
                            // Update user id for SDKUser
                            identity?.network.oauthProvider.sdkUserOAuth.userId = user?.userId
                            completion(success: error == nil)
                        }
                    }
            }
        })
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
                    completion(success: false)
                    return
                }

                applicationPipeline.callback = { [weak self] (returnedOperation) in
                    guard let identity = self else {
                        completion(success: false)
                        return
                    }
                    
                    if let error = returnedOperation.output?.error {
                        switch error.code {
                            case AuthenticationError.CredentialError.rawValue:
                                identity.delegate.credentialsIncorrect()
                            case AuthenticationError.AccountDisabledError.rawValue:
                                identity.delegate.accountDisabled()
                            case AuthenticationError.AccountLockedError.rawValue:
                                identity.delegate.accountLocked()
                            case AuthenticationError.TokenInvalidOrExpired.rawValue:
                                identity.delegate.tokenInvalidOrExpired()
                            default: break
                        }
                        
                        completion(success: false)
                        return
                    }
                    
                    identity.createSDKUserRecursively(CreateSDKUserRetries,completion:completion)
                }
                
                identity.network.enqueueOperation(applicationPipeline)
            }
        }
    }
    
    override func shutdown() {
        // Nothing to do currently.
        super.shutdown()
    }
    
    // MARK:- Login
    
    @objc func login(withUsername username: String, password: String, callback: UserCallback) {
        var oauth = network.oauthProvider.loggedInUserOAuth
        oauth.updateCredentials(withUsername: username, password: password)
        
        network.oauthProvider.developerLoggedIn = false
        
        let pipeline = IntelligenceAPIPipeline(withOperations: [IntelligenceOAuthValidateOperation(), IntelligenceOAuthRefreshOperation(), IntelligenceOAuthLoginOperation()], oauth: oauth, configuration: configuration, network: network)
        
        pipeline.callback = { [weak self] (returnedOperation: IntelligenceAPIOperation) -> () in
            let returnedPipeline = returnedOperation as! IntelligenceAPIPipeline
            
            // Clear password from memory.
            if oauth.tokenType == .LoggedInUser {
                oauth.password = nil
            }
            
            if returnedPipeline.output?.error != nil {
                // Failed, tell developer!
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
        IntelligenceOAuth.reset(network.oauthProvider.loggedInUserOAuth)
    }
    
    
    // MARK: - User Management

    @objc func assignRole(roleId: Int, user: Intelligence.User, callback: UserCallback) {
        let operation = AssignUserRoleRequestOperation(roleId: roleId, user: user, oauth: network.oauthProvider.applicationOAuth,
            configuration: configuration, network: network, callback: { (returnedOperation: IntelligenceAPIOperation) -> () in
                let assignRoleOperation = returnedOperation as! AssignUserRoleRequestOperation
                callback(user: assignRoleOperation.user, error: assignRoleOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation)
    }
    
    @objc func revokeRole(roleId: Int, user: Intelligence.User, callback: UserCallback) {
        let operation = RevokeUserRoleRequestOperation(roleId: roleId, user: user, oauth: network.oauthProvider.applicationOAuth,
            configuration: configuration, network: network, callback: { (returnedOperation: IntelligenceAPIOperation) -> () in
                let revokeRoleOperation = returnedOperation as! RevokeUserRoleRequestOperation
                callback(user: revokeRoleOperation.user, error: revokeRoleOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation)
    }
    
    @objc func updateUser(user: Intelligence.User, callback: UserCallback) {
        if !user.isValidToUpdate {
            callback(user:nil, error: NSError(code: IdentityError.InvalidUserError.rawValue) )
            return
        }
        
        // The password can be nil due to the fact that getting a user does not retrieve the password
        if user.password != nil && !user.isPasswordSecure() {
            callback(user:nil, error: NSError(code: IdentityError.WeakPasswordError.rawValue) )
            return
        }
        
        let operation = UpdateUserRequestOperation(user: user, oauth: network.oauthProvider.loggedInUserOAuth,
            configuration: configuration, network: network, callback: { (returnedOperation: IntelligenceAPIOperation) -> () in
                let updateOperation = returnedOperation as! UpdateUserRequestOperation
                callback(user: updateOperation.user, error: updateOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation)
    }
    
    @objc func getUser(userId: Int, callback: UserCallback) {
        let operation = GetUserRequestOperation(userId: userId, oauth: network.oauthProvider.applicationOAuth, configuration: configuration, network: network, callback: { (returnedOperation: IntelligenceAPIOperation) -> () in
            let getUserOperation = returnedOperation as! GetUserRequestOperation
            callback(user: getUserOperation.user, error: getUserOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation)
    }
    
    internal func getMe(oauth: IntelligenceOAuthProtocol, callback: UserCallback) {
        let operation = GetUserMeRequestOperation(oauth: oauth, configuration: configuration, network: network, callback: { (returnedOperation: IntelligenceAPIOperation) -> () in
            let getMeOperation = returnedOperation as! GetUserMeRequestOperation
            callback(user: getMeOperation.user, error: getMeOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation)
    }
    
    @objc func getMe(callback: UserCallback) {
        getMe(network.oauthProvider.loggedInUserOAuth, callback: callback)
    }
    
    // MARK: Internal
    
    /// Registers a user in the backend.
    /// - Parameters:
    ///     - user: Intelligence User instance containing information about the user we are trying to create.
    ///     - callback: The user callback to pass. Will be called with either an error or a user.
    /// The developer is responsible to dispatch the callback to the main thread using dispatch_async if necessary.
    /// - Throws: Returns an NSError in the callback using as code IdentityError.InvalidUserError when the
    /// user is invalid, or one of the RequestError errors.
    internal func createUser(user: Intelligence.User, callback: UserCallback? = nil) {
        if !user.isValidToCreate {
            callback?(user:nil, error: NSError(code: IdentityError.InvalidUserError.rawValue) )
            return
        }
        
        if !user.isPasswordSecure() {
            callback?(user:nil, error: NSError(code: IdentityError.WeakPasswordError.rawValue) )
            return
        }
        
        // Create user operation.
        let operation = CreateUserRequestOperation(user: user, oauth: network.oauthProvider.applicationOAuth, configuration: configuration, network: network, callback: { [weak self] (returnedOperation: IntelligenceAPIOperation) -> () in
            let createUserOperation = returnedOperation as! CreateUserRequestOperation
            if createUserOperation.output?.error == nil && createUserOperation.user != nil {
                // On successful operation, lets assign users role.
                
                guard let roleId = self?.configuration.sdkUserRole else {
                    self?.delegate.userRoleAssignmentFailed()
                    return
                }
                
                guard let user = createUserOperation.user else {
                    self?.delegate.userRoleAssignmentFailed()
                    return
                }
                
                self?.assignRole(roleId, user: user, callback: { (user, error) -> Void in
                    // Execute original callback.
                    // If assign role fails, the user will exist but not have any access, there is nothing we can do
                    // if the developer is trying to assign a role that doesn't exist or the server changes in some
                    // unexpected way.
                    if error != nil {
                        // Note: Assign role will also call a delegate method if it fails because the Intelligence
                        // backend may be configured incorrectly.
                        // We don't receive a unique error code, so just call the delegate on any error.
                        self?.delegate.userRoleAssignmentFailed()
                        // Also call callback, so developer doesn't get stuck waiting for a response.
                        callback?(user: nil, error: error)
                    } else {
                        callback?(user: user, error: error)
                    }
                })
            } else {
                // On failure, simply execute callback.
                callback?(user: createUserOperation.user, error: createUserOperation.output?.error)
            }
        })
        
        // Execute the network operation
        network.enqueueOperation(operation)
    }
    
    // MARK:- Identifiers
    
    func registerDeviceToken(data: NSData, callback: RegisterDeviceTokenCallback) {
        let token = data.hexString()
        
        unregisterDeviceTokenOnBehalf(token) { [weak self] (error) -> Void in
            self?.registerDeviceToken(token, callback: callback)
        }
    }
    
    private func registerDeviceToken(token: String, callback: RegisterDeviceTokenCallback) {
        if token.characters.count == 0 || token.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) == 0 {
            callback(tokenId: InvalidDeviceTokenID, error: NSError(code: IdentityError.DeviceTokenInvalidError.rawValue))
            return
        }
        let operation = CreateIdentifierRequestOperation(token: token,
            oauth: network.oauthProvider.bestPasswordGrantOAuth,
            configuration: configuration,
            network: network,
            callback: {
                (returnedOperation: IntelligenceAPIOperation) -> () in
                let createIdentifierOperation = returnedOperation as! CreateIdentifierRequestOperation
                callback(tokenId: createIdentifierOperation.tokenId ?? InvalidDeviceTokenID, error: createIdentifierOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation)
    }
    
    func unregisterDeviceToken(withId tokenId: Int, callback: UnregisterDeviceTokenCallback) {
        if tokenId < 1 {
            callback(error: NSError(code: IdentityError.DeviceTokenInvalidError.rawValue))
            return
        }
        let operation = DeleteIdentifierRequestOperation(tokenId: tokenId,
            oauth: network.oauthProvider.bestPasswordGrantOAuth,
            configuration: configuration,
            network: network,
            callback: {
                (returnedOperation: IntelligenceAPIOperation) -> () in
                let deleteIdentifierOperation = returnedOperation as! DeleteIdentifierRequestOperation
                callback(error:deleteIdentifierOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation)
    }
    
    private func unregisterDeviceTokenOnBehalf(token: String, callback: UnregisterDeviceTokenOnBehalfCallback) {
        if token.characters.count == 0 {
            callback(error: NSError(code: IdentityError.DeviceTokenInvalidError.rawValue))
            return
        }
        let operation = DeleteIdentifierOnBehalfRequestOperation(token: token,
            oauth: network.oauthProvider.applicationOAuth,
            configuration: configuration,
            network: network,
            callback: {
                (returnedOperation: IntelligenceAPIOperation) -> () in
                let deleteIdentifierOnBehalfOperation = returnedOperation as! DeleteIdentifierOnBehalfRequestOperation
                callback(error:deleteIdentifierOnBehalfOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation)
    }
    
    
    // MARK:- Installation
    
    /// Schedules a create installation request if first install.
    /// - Parameters:
    ///     - installation: Optional installation object to use instead of self.installation.
    ///     - callback: Optionally provide a callback to fire on completion.
    internal func createInstallation(callback: InstallationCallback? = nil) {
        if !installation.isNewInstallation {
            callback?(installation: installation, error: NSError(code: InstallationError.AlreadyInstalledError.rawValue))
            return
        }
        
        let operation = CreateInstallationRequestOperation(installation: installation, oauth: network.oauthProvider.bestPasswordGrantOAuth, configuration: configuration, network: network, callback: { (returnedOperation: IntelligenceAPIOperation) -> () in
            let createInstallationOperation = returnedOperation as! CreateInstallationRequestOperation
            callback?(installation: createInstallationOperation.installation, error: createInstallationOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation)
    }
    
    /// Schedules an update installation request if version number changed.
    /// - Parameters:
    ///     - callback: Optionally provide a callback to fire on completion.
    internal func updateInstallation(callback: InstallationCallback? = nil) {
        if !installation.isUpdatedInstallation {
            callback?(installation: installation, error: NSError(code: InstallationError.AlreadyUpdatedError.rawValue))
            return
        }
        
        // If this call fails, it will retry again the next time we open the app.
        let operation = UpdateInstallationRequestOperation(installation: installation, oauth: network.oauthProvider.bestPasswordGrantOAuth, configuration: configuration, network: network, callback: { (returnedOperation: IntelligenceAPIOperation) -> () in
            let updateInstallationOperation = returnedOperation as! UpdateInstallationRequestOperation
            callback?(installation: updateInstallationOperation.installation, error: updateInstallationOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation)
    }
}