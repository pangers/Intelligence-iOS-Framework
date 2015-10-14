//
//  PhoenixManager.swift
//  PhoenixDemo-Swift
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import PhoenixSDK

class PhoenixManager {
    
    private static let sharedInstance = PhoenixManager()
    
    private let locationManager = PhoenixLocationManager()
    private var phoenix: Phoenix?
    
    static var phoenix: Phoenix? {
        return sharedInstance.phoenix
    }
    
    init() {
        // Request location
        locationManager.requestAuthorization()
        
        do {
            phoenix = try Phoenix(withFile: "PhoenixConfiguration")
            
            // Startup all modules.
            phoenix?.startup { (error) -> () in
                print("Fundamental error occurred \(error)")
            }
            
            // Register test event.
            let testEvent = Phoenix.Event(withType: "Phoenix.Test.Event.Type")
            phoenix?.analytics.track(testEvent)
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
}