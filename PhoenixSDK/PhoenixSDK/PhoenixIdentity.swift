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
public protocol PhoenixIdentity : PhoenixModule {
    
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
        
        /// Default initializer. Requires a network.
        /// - Parameter network: The network that will be used.
        init(withNetwork network:Network) {
            self.network = network
        }
        
        func startup() {
            // stub
        }
        
        func createUser(user:PhoenixUser, callback:PhoenixUserCallback?) {
            // stub
        }
        
        func getMe(callback:PhoenixUserCallback?) {
            // stub
        }
        
        func getUser(userId:Int, callback:PhoenixUserCallback?) {
            // stub
        }
        
        func updateUser(user:PhoenixUser, callback:PhoenixUserCallback?) {
            // stub
        }

    }
}