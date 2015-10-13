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
                let testEvent = Event(withType: "Phoenix.Test.Event.Type")
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

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        PhoenixManager.phoenix.analytics.pause()
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        PhoenixManager.phoenix.analytics.resume()
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        PhoenixManager.phoenix.shutdown()
	}

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        PhoenixManager.phoenix.identity.registerDeviceToken(deviceToken) { (tokenId, error) -> Void in
            if error != nil {
                self.alert(withError: error!)
            } else {
                // Store token id for unregistration. For this example I have stored it in user defaults.
                // However, this should be stored in the keychain as the app may be uninstalled and reinstalled
                // multiple times and may receive the same device token from Apple.
                NSUserDefaults.standardUserDefaults().setInteger(tokenId, forKey: PhoenixDemoStoredDeviceTokenKey)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                self.alert(withMessage: "Registration Succeeded!")
            }
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        self.alert(withMessage: "Unable to Register for Push Notifications")
    }
    
    // MARK:- PhoenixDelegate
    
    func alert(withError error: NSError) {
        if error.domain == IdentityError.domain {
            alert(withMessage: "Failed: \(IdentityError(rawValue: error.code)!)")
        } else if error.domain == RequestError.domain {
            alert(withMessage: "Failed: \(RequestError(rawValue: error.code)!)")
        } else {
            alert(withMessage: "Unknown Error Occurred")
        }
    }
    
    func alert(withMessage message: String) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
            let controller = UIAlertController(title: "Phoenix Demo", message: message, preferredStyle: .Alert)
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

