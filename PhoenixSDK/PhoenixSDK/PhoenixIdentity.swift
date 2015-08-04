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
public typealias PhoenixUserCallback = (user:PhoenixUser?, error:NSError?) -> Void

/// The Phoenix Idenity module protocol. Defines the available API calls that can be performed.
@objc public protocol PhoenixIdentity : PhoenixModule {
    
    /// Creates a user in the backend.
    /// - Parameters:
    ///     - user: The PhoenixUser to create.
    ///     - callback: The user callback to pass. Will be called with either an error or a user.
    func createUser(user:PhoenixUser, callback:PhoenixUserCallback?)

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
    func updateUser(user:PhoenixUser, callback:PhoenixUserCallback?)

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
        
        @objc func createUser(user:PhoenixUser, callback:PhoenixUserCallback?) {
            let operation = CreateUserRequestOperation(session: network.sessionManager, user: user, authentication: network.authentication, configuration: configuration)
            
            // set the completion block to notify the caller
            operation.completionBlock = {
                guard let callback = callback else {
                    return;
                }
                callback(user: operation.createdUser, error: operation.error)
            }
            
            // Execute the network operation
            network.executeNetworkOperation(operation)
        }
        
        @objc func getMe(callback:PhoenixUserCallback?) {
            // stub
            let operation = GetUserMeRequestOperation(session: network.sessionManager, authentication: network.authentication, configuration: configuration)
            operation.completionBlock = {
                guard let callback = callback else {
                    return
                }
                callback(user: operation.meUser, error: operation.error)
            }
            
            // Execute the network operation
            network.executeNetworkOperation(operation)
        }
        
        @objc func getUser(userId:Int, callback:PhoenixUserCallback?) {
            // stub
        }
        
        @objc func updateUser(user:PhoenixUser, callback:PhoenixUserCallback?) {
            // stub
        }

    }
}