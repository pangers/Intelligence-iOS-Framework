//
//  PhoenixManager.swift
//  PhoenixDemo-Swift
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import Foundation

import PhoenixSDK


class PhoenixManager {
    
    static var manager:PhoenixManager = PhoenixManager()
    
    private(set) var phoenix:Phoenix?
    
    init(){
        do {
            self.phoenix = try Phoenix(withFile: "PhoenixConfiguration")
        }
        catch PhoenixSDK.ConfigurationError.FileNotFoundError {
            // The file you specified does not exist!
        }
        catch PhoenixSDK.ConfigurationError.InvalidFileError {
            // The file is invalid! Check that the JSON provided is correct.
        }
        catch PhoenixSDK.ConfigurationError.MissingPropertyError {
            // You missed a property!
        }
        catch PhoenixSDK.ConfigurationError.InvalidPropertyError {
            // There is an invalid property!
        }
        catch {
            // Treat the error with care!
        }
    }
    
    static func startup() {
        PhoenixManager.manager.phoenix?.startup(withCallback: { (authenticated) -> () in
            
        })
    }
}