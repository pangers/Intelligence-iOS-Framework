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

    /// Get details about logged in user.
    /// - parameter callback: Will be called with either an error or a user.
    func getMe(callback: @escaping UserCallback)
    
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
    

    override func startup(completion: @escaping (Bool) -> ()) {
        sharedIntelligenceLogger.logger?.info("Identity Module startup....")

        super.startup { [weak network, weak configuration] (success) -> () in
            if !success {
                sharedIntelligenceLogger.logger?.error("Identity Module startup failed")
                completion(false)
                return
            }
            guard let network = network, let configuration = configuration else {
                sharedIntelligenceLogger.logger?.error("Identity Module startup failed")
                completion(false)
                return
            }
            
            var oauth = network.oauthProvider.applicationOAuth
            oauth.username = configuration.userName
            oauth.password = configuration.userPassword
            
            // Get pipeline for grant_type 'client_credentials'.
            network.getPipeline(forOAuth: oauth, configuration: configuration) { [weak self] (applicationPipeline) -> () in
                guard let applicationPipeline = applicationPipeline, let identity = self else {
                    sharedIntelligenceLogger.logger?.error("Identity Module startup failed")
                    completion(false)
                    return
                }

                applicationPipeline.callback = { [weak self] (returnedOperation) in
                    guard let identity = self else {
                        sharedIntelligenceLogger.logger?.error("Identity Module startup failed")
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
                        sharedIntelligenceLogger.logger?.error("Identity Module startup failed")
                        completion(false)
                        return
                    }
                    
                    
                    // Installation can succeed without a user id
                    identity.createInstallation(callback: { (installation, error) in
                        if nil == error {
                            EventTypes.ApplicationInstall.saveToUserDefault(Obj: true)
                        }
                    })
                    
                    identity.updateInstallation(callback: { (installation, error) in
                        if nil == error {
                            EventTypes.ApplicationUpdate.saveToUserDefault(Obj: true)
                        }
                    })
                    
                    completion(true)
                }
                
                identity.network.enqueueOperation(operation: applicationPipeline)
            }
        }
    }
    
    override func shutdown() {
        // Nothing to do currently.
        sharedIntelligenceLogger.logger?.info("Identity Module Shutdown")
        super.shutdown()
    }
    
    // MARK:- Login
    
    @objc func login(with username: String, password: String, callback: @escaping UserCallback) {
        
        sharedIntelligenceLogger.logger?.info("Login user")
        
        var oauth = network.oauthProvider.loggedInUserOAuth
        oauth.updateCredentials(withUsername: username, password: password)
        
        network.oauthProvider.developerLoggedIn = false
        
        let pipeline = IntelligenceAPIPipeline(withOperations: [IntelligenceOAuthValidateOperation(), IntelligenceOAuthRefreshOperation(), IntelligenceOAuthLoginOperation()], oauth: oauth, configuration: configuration, network: network)
        
        pipeline.callback = { [weak self] (returnedOperation: IntelligenceAPIOperation) -> () in
            let returnedPipeline = returnedOperation as! IntelligenceAPIPipeline
            
            // Clear password from memory.
            if oauth.tokenType == .loggedInUser {
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
                    
                    let str = String(format:"Login user")
                    sharedIntelligenceLogger.logger?.info(str)
                    
                    // Notify developer
                    callback(user, error)
                })
            }
        }
        
        network.enqueueOperation(operation: pipeline)
    }
    
    @objc func logout() {
        sharedIntelligenceLogger.logger?.info("Logout user")

        network.oauthProvider.developerLoggedIn = false
        IntelligenceOAuth.reset(oauth: &network.oauthProvider.loggedInUserOAuth)
    }
    
    
    internal func getMe(oauth: IntelligenceOAuthProtocol, callback: @escaping UserCallback) {
    
        let operation = GetUserMeRequestOperation(oauth: oauth, configuration: configuration, network: network, callback: { (returnedOperation: IntelligenceAPIOperation) -> () in
            
            let getMeOperation = returnedOperation as! GetUserMeRequestOperation

            let str = (getMeOperation.output?.error == nil) ? String(format:"Get me(User) sucess ---> %d",(getMeOperation.user?.userId)!) : String(format:"Get me(User) failed")
            sharedIntelligenceLogger.logger?.info(str)
            
            callback(getMeOperation.user, getMeOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation: operation)
    }
    
    @objc func getMe(callback: @escaping UserCallback) {
        getMe(oauth: network.oauthProvider.loggedInUserOAuth, callback: callback)
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
            sharedIntelligenceLogger.logger?.error("Register device token failed! InvalidDeviceTokenID ")
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
                
                let str = (createIdentifierOperation.output?.error == nil) ? String(format:"Register device token sucess - %@",token) : String(format:"Register device token failed - %@",token)
                sharedIntelligenceLogger.logger?.info(str)
                
                callback(createIdentifierOperation.tokenId ?? InvalidDeviceTokenID, createIdentifierOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation: operation)
    }
    
    func unregisterDeviceToken(with tokenId: Int, callback: @escaping UnregisterDeviceTokenCallback) {
      
        if tokenId < 1 {
            sharedIntelligenceLogger.logger?.error("UnRegister device token!!! InvalidDeviceTokenID ")
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
                
                let str = (deleteIdentifierOperation.output?.error == nil) ? String(format:"UnRegister device token sucess - %d",tokenId) : String(format:"UnRegister device token failed - %d",tokenId)
                sharedIntelligenceLogger.logger?.info(str)
                
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
        
            let operation = CreateInstallationRequestOperation(installation: installation, oauth: network.oauthProvider.applicationOAuth, configuration: configuration, network: network, callback: { (returnedOperation: IntelligenceAPIOperation) -> () in
    
            
            let createInstallationOperation = returnedOperation as! CreateInstallationRequestOperation
            
            let str = (createInstallationOperation.output?.error == nil) ? "New-Installation event creation Failed" : "New-Installation event get Created";
            sharedIntelligenceLogger.logger?.info(str)

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

            let operation = UpdateInstallationRequestOperation(installation: installation, oauth: network.oauthProvider.applicationOAuth, configuration: configuration, network: network, callback: { (returnedOperation: IntelligenceAPIOperation) -> () in

            let updateInstallationOperation = returnedOperation as! UpdateInstallationRequestOperation
            
            let str = (updateInstallationOperation.output?.error == nil) ? "Update event creation Failed" : "Update event get Created";
            sharedIntelligenceLogger.logger?.info(str)
            
            callback?(updateInstallationOperation.installation, updateInstallationOperation.output?.error)
        })
        
        // Execute the network operation
        network.enqueueOperation(operation: operation)
    }
}
