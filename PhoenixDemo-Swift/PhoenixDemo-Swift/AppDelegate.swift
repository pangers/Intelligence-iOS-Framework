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
class AppDelegate: UIResponder, UIApplicationDelegate, PhoenixDelegate {

	var window: UIWindow?
    
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        do {
            let phoenix = try Phoenix(withDelegate: self, file: "PhoenixConfiguration")
            let semaphore = dispatch_semaphore_create(0)
            
            // Startup all modules.
            phoenix.startup { (success) -> () in
                assert(success, "Phoenix could not startup")
                
                // Register test event.
                let testEvent = Phoenix.Event(withType: "Phoenix.Test.Event.Type")
                phoenix.analytics.track(testEvent)
                
                PhoenixManager.startupWithPhoenix(phoenix)
                dispatch_semaphore_signal(semaphore)
            }
            
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER)
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
        
		return true
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        PhoenixManager.phoenix.shutdown()
	}

    // MARK:- PhoenixDelegate
    
    func alert(withMessage message: String) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            let controller = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
            controller.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            self?.window?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
        }
    }
    
    func userCreationFailedForPhoenix(phoenix: Phoenix) {
        alert(withMessage: "Unrecoverable error occurred during user creation, check Phoenix Intelligence accounts are configured correctly.")
    }
    
    func userLoginRequiredForPhoenix(phoenix: Phoenix) {
        // Present login screen or call identity.login with credentials stored in Keychain.
        alert(withMessage: "Token expired, you will need to login again.")
    }
    
    func userRoleAssignmentFailedForPhoenix(phoenix: Phoenix) {
        alert(withMessage: "Unrecoverable error occurred during user role assignment, if this happens consistently please confirm that Phoenix Intelligence accounts are configured correctly.")
    }
}

