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

/// The Phoenix Idenity module protocol. Defines the available API calls that can be performed.
@objc public protocol PhoenixIdentity : PhoenixModule {
    
    /// - Returns: True if user has logged in with username and password.
    var loggedIn: Bool { get }
    
    /// Attempt to authenticate with a username and password.
    /// Logging in with associate events with this user.
    /// - Parameters
    ///     - username: Username of account to attempt login with.
    ///     - password: Password associated with username.
    ///     - callback: The user callback to pass. Will be called with either an error or a user.
    func login(withUsername username: String, password: String, callback: PhoenixUserCallback)
    
    /// Logging out will no longer associate events with the authenticated user.
    func logout()
    
    /// Registers a user in the backend.
    /// - Parameters:
    ///     - user: The PhoenixUser to create.
    ///     - callback: The user callback to pass. Will be called with either an error or a user.
    /// The queue on which the callback is called is not guaranteed. It might or might not be the main thread.
    /// The developer is responsible to dispatch it to the main thread using dispatch_async to avoid deadlocks.
    /// - Throws: Returns an NSError in the callback using as code IdentityError.InvalidUserError when the
    /// user is invalid, and IdentityError.UserCreationError when there is an error while creating it.
    /// The NSError domain is IdentityError.domain
    func createUser(user:Phoenix.User, callback:PhoenixUserCallback?)

    /// Gets a user data from a given user Id.
    /// - Parameters:
    ///     - userId: The user id to look for.
    ///     - callback: The user callback to pass. Will be called with either an error or a user.
    func getUser(userId:Int, callback:PhoenixUserCallback?)
    
    /// Updates a user in the backend.
    /// - Parameters:
    ///     - user: The PhoenixUser to create.
    ///     - callback: The user callback to pass. Will be called with either an error or a user.
    func updateUser(user:Phoenix.User, callback:PhoenixUserCallback?)

}

extension Phoenix {

    /// The PhoenixIdentity implementation.
    class Identity : PhoenixIdentity {

        /// A reference to the network manager
        private let network:Network
        
        /// The configuration of the Phoenix SDK
        private let configuration:PhoenixConfigurationProtocol
        
        /// Default initializer. Requires a network.
        /// - Parameter network: The network that will be used.
        init(withNetwork network:Network, withConfiguration configuration:PhoenixConfigurationProtocol) {
            self.network = network
            self.configuration = configuration
        }
        
        @objc func startup() {
            // stub
        }
        
        
        // MARK:- Login
        
        @objc var loggedIn: Bool {
            return network.authentication.userId != nil
        }
        
        @objc func login(withUsername username: String, password: String, callback: PhoenixUserCallback) {
            // Force application login first, since this won't be triggered by adding an item to the authentication queue.
            network.enqueueAuthenticationOperationIfRequired()
            // Create login operation...
            let loginOperation = Phoenix.AuthenticationRequestOperation(network: network, configuration: configuration, username: username, password: password, callback: { [weak self] (json) -> () in
                // Perform get me request with this access token
                if let accessToken = json?[accessTokenKey] as? String {
                    self?.getMe(accessToken, callback: callback)
                } else {
                    callback(user: nil, error: NSError(domain: RequestError.domain, code: RequestError.RequestFailedError.rawValue, userInfo: nil))
                }
            })
            network.authenticateQueue.addOperation(loginOperation)
        }
        
        @objc func logout() {
            // Clear userid.
            network.authentication.userId = nil
        }
        
        
        // MARK: - User Management
        
        @objc func createUser(user:Phoenix.User, callback:PhoenixUserCallback?) {
            if !user.isValidToCreate {
                callback?(user:nil, error: NSError(domain:IdentityError.domain, code: IdentityError.InvalidUserError.rawValue, userInfo: nil) )
                return
            }
            
            if !user.isPasswordSecure() {
                callback?(user:nil, error: NSError(domain:IdentityError.domain, code: IdentityError.WeakPasswordError.rawValue, userInfo: nil) )
                return
            }
            
            let operation = CreateUserRequestOperation(session: network.sessionManager, user: user, authentication: network.authentication, configuration: configuration)
            
            // set the completion block to notify the caller
            operation.completionBlock = {
                callback?(user:operation.user, error:operation.error)
            }
            
            // Execute the network operation
            network.executeNetworkOperation(operation)
        }
        
        @objc func getUser(userId:Int, callback:PhoenixUserCallback?) {
            if !Phoenix.User.isUserIdValid(userId) {
                callback?(user:nil, error: NSError(domain:IdentityError.domain, code: IdentityError.InvalidUserError.rawValue, userInfo: nil) )
                return
            }
            
            let operation = GetUserByIdRequestOperation(session: network.sessionManager, userId: userId, authentication: network.authentication, configuration: configuration)
            
            operation.completionBlock = {
                callback?(user:operation.user, error:operation.error)
            }
            
            network.executeNetworkOperation(operation)
        }
        
        @objc func updateUser(user:Phoenix.User, callback:PhoenixUserCallback?) {
            // stub
        }

        
        // MARK:- Private
        
        /// Gets a user data from the current user credentials.
        /// - Parameters:
        ///     - temporaryAccessToken: Only used by 'getUserMe' and is the access_token we receive from the 'login' and is discarded immediately after this call.
        ///     - callback: The user callback to pass. Will be called with either an error or a user.
        @objc private func getMe(temporaryAccessToken: String, callback:PhoenixUserCallback) {
            let operation = GetUserMeRequestOperation(session: network.sessionManager, authentication: network.authentication, configuration: configuration, callback: callback)
            
            // This operation will use a temporary access token obtained from login request.
            operation.temporaryAccessToken = temporaryAccessToken
            
            // Execute the network operation
            network.executeNetworkOperation(operation)
        }
    }
}