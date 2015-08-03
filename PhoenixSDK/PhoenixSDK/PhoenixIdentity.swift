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
public protocol PhoenixIdentity : PhoenixModuleProtocol {
    
    /// Creates a user in the backend.
    /// - Parameters:
    ///     - user: The PhoenixUser to create.
    ///     - callback: The user callback to pass. Will be called with either an error or a user.
    /// - throws: ModuleError.StartupNotCalledError
    func createUser(user:PhoenixUser, callback:PhoenixUserCallback?) throws
    /// Gets a user data from the current user credentials.
    /// - Parameters:
    ///     - callback: The user callback to pass. Will be called with either an error or a user.
    /// - throws: ModuleError.StartupNotCalledError
    func getMe(callback:PhoenixUserCallback?) throws
    
    /// Gets a user data from a given user Id.
    /// - Parameters:
    ///     - userId: The user id to look for.
    ///     - callback: The user callback to pass. Will be called with either an error or a user.
    /// - throws: ModuleError.StartupNotCalledError
    func getUser(userId:Int, callback:PhoenixUserCallback?) throws
    
    /// Updates a user in the backend.
    /// - Parameters:
    ///     - user: The PhoenixUser to create.
    ///     - callback: The user callback to pass. Will be called with either an error or a user.
    /// - throws: ModuleError.StartupNotCalledError
    func updateUser(user:PhoenixUser, callback:PhoenixUserCallback?) throws

}

extension Phoenix {

    /// The PhoenixIdentity implementation.
    class Identity : PhoenixModule, PhoenixIdentity {

        /// A reference to the network manager
        private let network:Network
        
        /// Default initializer. Requires a network.
        /// - Parameter network: The network that will be used.
        init(withNetwork network:Network) {
            self.network = network
        }
        
        /// Overridden startup.
        override func startup() {
            super.startup()
        }
        
        func createUser(user:PhoenixUser, callback:PhoenixUserCallback?) throws {
            if !self.didStartup {
                throw ModuleError.StartupNotCalledError
            }
        
            // stub
        }
        
        func getMe(callback:PhoenixUserCallback?) throws {
            if !self.didStartup {
                throw ModuleError.StartupNotCalledError
            }
          
            // stub
        }
        
        func getUser(userId:Int, callback:PhoenixUserCallback?) throws {
            if !self.didStartup {
                throw ModuleError.StartupNotCalledError
            }
         
            // stub
        }
        
        func updateUser(user:PhoenixUser, callback:PhoenixUserCallback?) throws {
            if !self.didStartup {
                throw ModuleError.StartupNotCalledError
            }

            // stub
        }

    }
}