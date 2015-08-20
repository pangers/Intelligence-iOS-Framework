//
//  PhoenixManager.swift
//  PhoenixDemo-Swift
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import PhoenixSDK

class PhoenixManager {
    
    static let manager: PhoenixManager = PhoenixManager()
    
    private let locationManager: PhoenixLocationManager
    internal var phoenix: Phoenix?
    
    init(){
        locationManager = PhoenixLocationManager()
        do {
            phoenix = try Phoenix(withFile: "PhoenixConfiguration")
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
    
    func startup() {
        // Startup all modules.
        phoenix?.startup { (error) -> () in
            print("Fundamental error occurred \(error)")
        }
        locationManager.requestAuthorization()
        // Register test event.
        let testEvent = Phoenix.Event(withType: "Phoenix.Test.Event.Type")
        phoenix?.analytics.track(testEvent)
    }
}