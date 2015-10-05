//
//  AppDelegate.swift
//  PhoenixDemo-Swift
//
//  Created by Rui Silvestre on 20/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit

import PhoenixSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
    
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {       
        do {
            let phoenix = try Phoenix(withFile: "PhoenixConfiguration")
            PhoenixManager.startupWithPhoenix(phoenix)
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
        
        // Startup all modules.
        PhoenixManager.phoenix?.startup { (error) -> () in
            print("Fundamental error occurred \(error)")
        }

        // Register test event.
        let testEvent = Phoenix.Event(withType: "Phoenix.Test.Event.Type")
        PhoenixManager.phoenix?.analytics.track(testEvent)
        
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        PhoenixManager.phoenix?.shutdown()
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        PhoenixManager.phoenix?.startup({ (error) -> () in
            print("Fundamental error occurred \(error)")
        })
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        PhoenixManager.phoenix?.shutdown()
	}


}

