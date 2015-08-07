//
//  PhoenixIdentity.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// A generic network callback, passing an optional error if the call failed.
public typealias PhoenixNetworkErrorCallback = (error:NSError?) -> Void

/// A generic PhoenixUserCallback in which we get either a PhoenixUser or an error.
public typealias PhoenixUserCallback = (user:Phoenix.User?, error:NSError?) -> Void

/// The Phoenix Idenity module protocol. Defines the available API calls that can be performed.
@objc public protocol PhoenixIdentity : PhoenixModule {
    
    /// Creates a user in the backend.
    /// - Parameters:
    ///     - user: The PhoenixUser to create.
    ///     - callback: The user callback to pass. Will be called with either an error or a user.
    /// The queue on which the callback is called is not guaranteed. It might or might not be the main thread.
    /// The developer is responsible to dispatch it to the main thread using dispatch_async to avoid deadlocks.
    /// - Throws: Returns an NSError in the callback using as code IdentityError.InvalidUserError when the
    /// user is invalid, and IdentityError.UserCreationError when there is an error while creating it.
    /// The NSError domain is IdentityError.domain
    func createUser(user:Phoenix.User, callback:PhoenixUserCallback?)

    /// Gets a user data from the current user credentials.
    /// - Parameters:
    ///     - callback: The user callback to pass. Will be called with either an error or a user.
    func getMe(callback:PhoenixUserCallback?)
    
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
        
        @objc func getMe(callback:PhoenixUserCallback?) {
            let operation = GetUserMeRequestOperation(session: network.sessionManager, authentication: network.authentication, configuration: configuration)
            
            operation.completionBlock = {
                callback?(user:operation.user, error:operation.error)
            }
            
            // Execute the network operation
            network.executeNetworkOperation(operation)
        }
        
        @objc func getUser(userId:Int, callback:PhoenixUserCallback?) {
            if !Phoenix.User.isUserIdValid(userId) {
                callback?(user:nil, error: NSError(domain:IdentityError.domain, code: IdentityError.GetUserError.rawValue, userInfo: nil) )
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

    }
}