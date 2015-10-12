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

    private let locationManager = PhoenixLocationManager()

	var window: UIWindow?
    
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
        // Request location
        locationManager.requestAuthorization()
        
        do {
            let phoenix = try Phoenix(withDelegate: self, file: "PhoenixConfiguration")
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
        PhoenixManager.phoenix.startup { (success) -> () in
            assert(success, "Phoenix could not startup")
        }

        // Register test event.
        let testEvent = Phoenix.Event(withType: "Phoenix.Test.Event.Type")
        PhoenixManager.phoenix.analytics.track(testEvent)
        
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        PhoenixManager.phoenix.shutdown()
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        PhoenixManager.phoenix.startup({ (success) -> () in
            assert(success, "Phoenix could not startup")
        })
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        PhoenixManager.phoenix.shutdown()
	}

    // MARK:- PhoenixDelegate
    
    func alert(withMessage message: String) {
        let presenterViewController = window?.rootViewController
        if !NSThread.isMainThread() ||
            presenterViewController?.canBecomeFirstResponder() == false ||
            presenterViewController?.presentedViewController != nil {
            dispatch_after(1, dispatch_get_main_queue(), { [weak self] () -> Void in
                self?.alert(withMessage: message)
            })
            return
        }
        let controller = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        controller.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
        presenterViewController?.presentViewController(controller, animated: true, completion: nil)
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

