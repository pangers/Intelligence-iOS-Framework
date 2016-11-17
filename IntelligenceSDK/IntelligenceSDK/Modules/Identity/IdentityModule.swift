//
//  IdentityModule.swift
//  IntelligenceSDK
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// A generic UserCallback in which we get either an IntelligenceUser or an error.
public typealias UserCallback = (Intelligence.User?, NSError?) -> Void

/// Called on completion of update or create installation request.
/// - Returns: Installation object and optional error.
internal typealias InstallationCallback = (Installation?, NSError?) -> Void

/// Callback for Register Device Token method, developer is responsbile for managing the tokenId and calling unregister at appropriate times.
public typealias RegisterDeviceTokenCallback = (Int, NSError?) -> Void
/// Callback for Unregister Device Token method, an error may occur if tokenId was not registred or is registered against another user.
public typealias UnregisterDeviceTokenCallback = (NSError?) -> Void
/// Callback for Unregister Device Token (On Befalf) method
public typealias UnregisterDeviceTokenOnBehalfCallback = (NSError?) -> Void

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
    func login(with username: String, password: String, callback: @escaping UserCallback)
    
    /// Logging out will no longer associate events with the authenticated user.
    func logout()

    /// Get details about a user.
    /// - parameter userId: The id of the user to retrieve details for.
    /// - parameter callback: Will be called with either an error or a user.
    func getUser(with userId: Int, callback: @escaping UserCallback)
    
    /// Assign a role to a user.
    /// - parameter roleId: The id of the role to assign.
    /// - parameter user: The user to assign the role to.
    /// - parameter callback: Will be called with either an error or a user.
    func assignRole(to roleId: Int, user: Intelligence.User, callback: @escaping UserCallback)
    
    /// Revoke a role from a user.
    /// - parameter roleId: The id of the role to revoke.
    /// - parameter user: The user to revoke the role from.
    /// - parameter callback: Will be called with either an error or a user.
    func revokeRole(with roleId: Int, user: Intelligence.User, callback: @escaping UserCallback)
    
    /// Get details about logged in user.
    /// - parameter callback: Will be called with either an error or a user.
    func getMe(callback: @escaping UserCallback)
    
    /// Updates a user in the backend.
    /// - Parameters:
    ///     - user: Intelligence User instance containing information about the user we are trying to update.
    ///     - callback: Will be called with either an error or a user.
    func update(user: Intelligence.User, callback: @escaping UserCallback)
    
    /// Register a push notification token on the Intelligence platform.
    /// - parameter data: Data received from 'application:didRegisterForRemoteNotificationsWithDeviceToken:' response.
    /// - parameter callback: Callback to fire on completion, will contain error or token ID. Developer should store token ID and is responsible for managing the flow of registration for push.
    func registerDeviceToken(with data: Data, callback: @escaping RegisterDeviceTokenCallback)
    
    /// Unregister a token ID in the backend, will fail if it was registered against another user.
    /// - parameter tokenId: Previously registered token ID. Should be unregistered prior to logout if you have multiple accounts.
    /// - parameter callback: Callback to fire on completion, error will be set if unable to unregister.
    func unregisterDeviceToken(with tokenId: Int, callback: @escaping UnregisterDeviceTokenCallback)
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
    
    private func createSDKUserIfRequired(completion: @escaping (Bool) -> ()) {
        var oauth = network.oauthProvider.sdkUserOAuth
        if oauth.username != nil && oauth.password != nil {
                completion(true)
                return
        }
        
        // Need to create user first.
        let sdkUser = Intelligence.User(companyId: configuration.companyId)
        let password = sdkUser.password
        
        createUser(user: sdkUser) { [weak self] (serverUser, error) -> Void in
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
    private func createSDKUserRecursively(counter: Int, completion: @escaping (Bool) -> ()) {
        if counter <= 1 {
            
            // Pass error back to developer (special case, use delegate).
            // Probably means that user already exists, or perhaps Application is configured incorrectly
            // and cannot create users.
            self.delegate?.userCreationFailed()
            
            completion(false)
            return
        }
        
        // Create user if their credentials are empty.
        self.createSDKUserIfRequired(completion: { [weak self] (success: Bool) -> () in
            guard let identity = self else {
                completion(false)
                return
            }
            
            if !success {
                identity.createSDKUserRecursively(counter: counter - 1, completion: completion)
                return
            }
            
            // Get pipeline if created or existing.
            identity.network.getPipeline(forOAuth: identity.network.oauthProvider.sdkUserOAuth, configuration: identity.configuration) { [weak self] (sdkUserPipeline) -> () in
                    
                    guard let identity = self, let sdkUserPipeline = sdkUserPipeline else {
                        // Should not happen (user created above)
                        completion(false)
                        return
                    }
                    
                    identity.network.enqueueOperation(operation: sdkUserPipeline)
                    
                    sdkUserPipeline.callback = { [weak self] (returnedOperation: IntelligenceAPIOperation) -> () in
                        guard let identity = self else {
                            completion(false)
                            return
                        }
                        
                        if let error = returnedOperation.output?.error {
                            switch error.code {
                                case AuthenticationError.credentialError.rawValue,
                                AuthenticationError.accountDisabledError.rawValue,
                                AuthenticationError.accountLockedError.rawValue,
                                AuthenticationError.tokenInvalidOrExpired.rawValue:
                                    IntelligenceOAuth.reset(oauth: &identity.network.oauthProvider.sdkUserOAuth)
                                    identity.createSDKUserRecursively(counter: counter - 1, completion: completion)
                                default:
                                    completion(false)
                            }
                            
                            return
                        }
                    
                        // Installation can succeed without a user id
                        identity.createInstallation(callback: nil)
                        identity.updateInstallation(callback: nil)
                        
                        // Grab our user ID.
                        identity.getMe(oauth: identity.network.oauthProvider.sdkUserOAuth) { [weak identity] (user, error) -> Void in
                            
                            // Update user id for SDKUser
                            identity?.network.oauthProvider.sdkUserOAuth.userId = user?.userId
                            completion(error == nil)
                        }
                    }
            }
        })
    }

    
    override func startup(completion: @escaping (Bool) -> ()) {
        super.startup { [weak network, weak configuration] (success) -> () in
            if !success {
                completion(false)
                return
            }
            guard let network = network, let configuration = configuration else {
                completion(false)
                return
            }
            
            // Get pipeline for grant_type 'client_credentials'.
            network.getPipeline(forOAuth: network.oauthProvider.applicationOAuth, configuration: configuration) { [weak self] (applicationPipeline) -> () in
                guard let applicationPipeline = applicationPipeline, let identity = self else {
                    completion(false)
                    return
                }

                applicationPipeline.callback = { [weak self] (returnedOperation) in
                    guard let identity = self else {
                        completion(false)
                        return
                    }
                    
                    if let error = returnedOperation.output?.error {
                        switch error.code {
                            case AuthenticationError.credentialError.rawValue:
                                identity.delegate.credentialsIncorrect()
                            case AuthenticationError.accountDisabledError.rawValue:
                                identity.delegate.accountDisabled()
                            case AuthenticationError.accountLockedError.rawValue:
                                identity.delegate.accountLocked()
                            case AuthenticationError.tokenInvalidOrExpired.rawValue:
                                identity.delegate.tokenInvalidOrExpired()
                            default: break
                        }
                        
                        completion(false)
                        return
                    }
                    
                    identity.createSDKUserRecursively(counter: CreateSDKUserRetries,completion:completion)
                }
                
                identity.network.enqueueOperation(operation: applicationPipeline)
            }
        }
    }
    
    override func shutdown() {
        // Nothing to do currently.
        super.shutdown()
    }
    
    // MARK:- Login
    
    @objc func login(with username: String, password: String, callback: @escaping UserCallback) {
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
                callback(nil, returnedPipeline.output?.error)
            } else {
                // Get user me.
                self?.getMe(callback: { (user, error) -> Void in
                    // Clear userid if get me fails, otherwise update user id.
                    oauth.userId = user?.userId
                    
                    // Logged in only if we have a user.
                    self?.network.oauthProvider.developerLoggedIn = oauth.userId != nil
                    
                    // Notify developer
                    callback(user, error)
                })
            }
        }
        
        network.enqueueOperation(operation: pipeline)
    }
    
    @objc func logout() {
        network.oauthProvider.developerLoggedIn = false
        IntelligenceOAuth.reset(oauth: &network.oauthProvider.loggedInUserOAuth)
    }
    
    
    // MARK: - User Management

    @objc func assignRole(to roleId: Int, user: Intelligence.User, callback: @escaping UserCallback) {
        let operation = AssignUserRoleRequestOperation(roleId: roleId, user: user, oauth: network.oauthProvider.applicationOAuth,
            configuration: configuration, network: network, callback: { (returnedOperation: IntelligenceAPIOperation) -> () in
                let assignRoleOperation = returnedOperation as! AssignUserRoleRequestOperation
                callback(assignRoleOperation.user, assignRoleOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation: operation)
    }
    
    @objc func revokeRole(with roleId: Int, user: Intelligence.User, callback: @escaping UserCallback) {
        let operation = RevokeUserRoleRequestOperation(roleId: roleId, user: user, oauth: network.oauthProvider.applicationOAuth,
            configuration: configuration, network: network, callback: { (returnedOperation: IntelligenceAPIOperation) -> () in
                let revokeRoleOperation = returnedOperation as! RevokeUserRoleRequestOperation
                callback(revokeRoleOperation.user, revokeRoleOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation: operation)
    }
    
    
    @objc func update(user: Intelligence.User, callback: @escaping UserCallback) {
        if !user.isValidToUpdate {
            callback(nil, NSError(code: IdentityError.invalidUserError.rawValue) )
            return
        }
        
        // The password can be nil due to the fact that getting a user does not retrieve the password
        if user.password != nil && !user.isPasswordSecure() {
            callback(nil, NSError(code: IdentityError.weakPasswordError.rawValue) )
            return
        }
        
        let operation = UpdateUserRequestOperation(user: user, oauth: network.oauthProvider.loggedInUserOAuth,
            configuration: configuration, network: network, callback: { (returnedOperation: IntelligenceAPIOperation) -> () in
                let updateOperation = returnedOperation as! UpdateUserRequestOperation
                callback(updateOperation.user, updateOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation:
            
            operation)
    }
    
    @objc func getUser(with userId: Int, callback: @escaping UserCallback) {
        let operation = GetUserRequestOperation(userId: userId, oauth: network.oauthProvider.applicationOAuth, configuration: configuration, network: network, callback: { (returnedOperation: IntelligenceAPIOperation) -> () in
            let getUserOperation = returnedOperation as! GetUserRequestOperation
            callback(getUserOperation.user, getUserOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation: operation)
    }
    
    internal func getMe(oauth: IntelligenceOAuthProtocol, callback: @escaping UserCallback) {
        let operation = GetUserMeRequestOperation(oauth: oauth, configuration: configuration, network: network, callback: { (returnedOperation: IntelligenceAPIOperation) -> () in
            let getMeOperation = returnedOperation as! GetUserMeRequestOperation
            callback(getMeOperation.user, getMeOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation: operation)
    }
    
    @objc func getMe(callback: @escaping UserCallback) {
        getMe(oauth: network.oauthProvider.loggedInUserOAuth, callback: callback)
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
            callback?(nil, NSError(code: IdentityError.invalidUserError.rawValue) )
            return
        }
        
        if !user.isPasswordSecure() {
            callback?(nil, NSError(code: IdentityError.weakPasswordError.rawValue) )
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
                
                self?.assignRole(to: roleId, user: user, callback: { (user, error) -> Void in
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
                        callback?(nil, error)
                    } else {
                        callback?(user, error)
                    }
                })
            } else {
                // On failure, simply execute callback.
                callback?(createUserOperation.user, createUserOperation.output?.error)
            }
        })
        
        // Execute the network operation
        network.enqueueOperation(operation: operation)
    }
    
    // MARK:- Identifiers
    
    func registerDeviceToken(with data: Data, callback: @escaping RegisterDeviceTokenCallback) {
        let token = data.hexString()
        
        unregisterDeviceTokenOnBehalf(token: token) { [weak self] (error) -> Void in
            self?.registerDeviceToken(token: token, callback: callback)
        }
    }
    
    private func registerDeviceToken(token: String, callback: @escaping RegisterDeviceTokenCallback) {
        if token.characters.count == 0 || token.lengthOfBytes(using: String.Encoding.utf8) == 0 {
            callback(InvalidDeviceTokenID, NSError(code: IdentityError.deviceTokenInvalidError.rawValue))
            return
        }
        let operation = CreateIdentifierRequestOperation(token: token,
            oauth: network.oauthProvider.bestPasswordGrantOAuth,
            configuration: configuration,
            network: network,
            callback: {
                (returnedOperation: IntelligenceAPIOperation) -> () in
                let createIdentifierOperation = returnedOperation as! CreateIdentifierRequestOperation
                callback(createIdentifierOperation.tokenId ?? InvalidDeviceTokenID, createIdentifierOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation: operation)
    }
    
    func unregisterDeviceToken(with tokenId: Int, callback: @escaping UnregisterDeviceTokenCallback) {
        if tokenId < 1 {
            callback(NSError(code: IdentityError.deviceTokenInvalidError.rawValue))
            return
        }
        let operation = DeleteIdentifierRequestOperation(tokenId: tokenId,
            oauth: network.oauthProvider.bestPasswordGrantOAuth,
            configuration: configuration,
            network: network,
            callback: {
                (returnedOperation: IntelligenceAPIOperation) -> () in
                let deleteIdentifierOperation = returnedOperation as! DeleteIdentifierRequestOperation
                callback(deleteIdentifierOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation: operation)
    }
    
    private func unregisterDeviceTokenOnBehalf(token: String, callback: @escaping UnregisterDeviceTokenOnBehalfCallback) {
        if token.characters.count == 0 {
            callback(NSError(code: IdentityError.deviceTokenInvalidError.rawValue))
            return
        }
        let operation = DeleteIdentifierOnBehalfRequestOperation(token: token,
            oauth: network.oauthProvider.applicationOAuth,
            configuration: configuration,
            network: network,
            callback: {
                (returnedOperation: IntelligenceAPIOperation) -> () in
                let deleteIdentifierOnBehalfOperation = returnedOperation as! DeleteIdentifierOnBehalfRequestOperation
                callback(deleteIdentifierOnBehalfOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation: operation)
    }
    
    
    // MARK:- Installation
    
    /// Schedules a create installation request if first install.
    /// - Parameters:
    ///     - installation: Optional installation object to use instead of self.installation.
    ///     - callback: Optionally provide a callback to fire on completion.
    internal func createInstallation(callback: InstallationCallback? = nil) {
        if !installation.isNewInstallation {
            callback?(installation, NSError(code: InstallationError.alreadyInstalledError.rawValue))
            return
        }
        
        let operation = CreateInstallationRequestOperation(installation: installation, oauth: network.oauthProvider.bestPasswordGrantOAuth, configuration: configuration, network: network, callback: { (returnedOperation: IntelligenceAPIOperation) -> () in
            let createInstallationOperation = returnedOperation as! CreateInstallationRequestOperation
            callback?(createInstallationOperation.installation, createInstallationOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation: operation)
    }
    
    /// Schedules an update installation request if version number changed.
    /// - Parameters:
    ///     - callback: Optionally provide a callback to fire on completion.
    internal func updateInstallation(callback: InstallationCallback? = nil) {
        if !installation.isUpdatedInstallation {
            callback?(installation, NSError(code: InstallationError.alreadyUpdatedError.rawValue))
            return
        }
        
        // If this call fails, it will retry again the next time we open the app.
        let operation = UpdateInstallationRequestOperation(installation: installation, oauth: network.oauthProvider.bestPasswordGrantOAuth, configuration: configuration, network: network, callback: { (returnedOperation: IntelligenceAPIOperation) -> () in
            let updateInstallationOperation = returnedOperation as! UpdateInstallationRequestOperation
            callback?(updateInstallationOperation.installation, updateInstallationOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation: operation)
    }
}
