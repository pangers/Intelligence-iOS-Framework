//
//  Phoenix.swift
//  PhoenixSDK
//
//  Created by Josep Rodriguez on 22/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

/// The main Phoenix entry point. Aggregates modules in it.
public class Phoenix {

    /// Private configuration. Can't be modified once initialized.
    private let configuration:PhoenixConfiguration
    
    /// Initializes the Phoenix entry point with a configuration object.
    /// - Parameter phoenixConfiguration: The configuration to use. The configuration
    /// will be copied to avoid future mutability.
    public init(phoenixConfiguration:PhoenixConfiguration){
        self.configuration = PhoenixConfiguration(copying: phoenixConfiguration)
    }
    
    /// Provides a convenience initializer with a file and bundle.
    /// ### Throws 
    /// Throws a PhoenixError.NoSuchConfigFile if the configuration file is not found.
    /// - Parameters:
    ///     - withFile: The JSON file name (no extension) of the configuration.
    ///     - inBundle: The bundle to use. Defaults to the main bundle.
    convenience public init(withFile:String, inBundle:NSBundle=NSBundle.mainBundle()) throws {
        try! self.init(phoenixConfiguration: PhoenixConfiguration(fromFile: withFile, inBundle: inBundle))
    }
    
    /// - Returns: A **copy** of the configuration.
    public func getConfiguration() -> PhoenixConfiguration {
        return PhoenixConfiguration(copying: self.configuration)
    }
}