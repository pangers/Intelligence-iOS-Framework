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
        
        startupPhoenix()

		return true
	}
    
    func startupPhoenix() {
        if PhoenixManager.phoenix != nil {
            return
        }
        
        do {
            let phoenix = try Phoenix(withDelegate: self, file: "PhoenixConfiguration")
            
            // Startup all modules.
            phoenix.startup { (success) -> () in
                
                NSOperationQueue.mainQueue().addOperationWithBlock {

                    if success {
                        // Register test event.
                        let testEvent = Event(withType: "Phoenix.Test.Event.Type")
                        phoenix.analytics.track(testEvent)
                        PhoenixManager.startupWithPhoenix(phoenix)
                        
                        self.segueToDemo()
                    }
                    else {
                            // Allow the user to retry to startup phoenix.
                            let message = "Phoenix was unable to initialise properly. This can lead to unexpected behaviour. Please restart the app to retry the Phoenix startup."
                            let controller = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
                            controller.addAction(UIAlertAction(title: "Retry", style: .Cancel, handler: { (action) -> Void in
                                // Try again to start phoenix
                                self.startupPhoenix()
                            }))
                            
                            self.window?.rootViewController?.presentViewController(controller, animated: true, completion: nil)

                    }
                }
            }
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
    

	func applicationDidEnterBackground(application: UIApplication) {
        PhoenixManager.phoenix.analytics.pause()
	}

	func applicationWillEnterForeground(application: UIApplication) {
        PhoenixManager.phoenix.analytics.resume()
	}

	func applicationWillTerminate(application: UIApplication) {
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
    
    func segueToDemo() {
        guard let viewController = self.window?.rootViewController else {
            return;
        }
        
        viewController.performSegueWithIdentifier("phoenixStartedUp", sender: self)
    }
    
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
        if !NSThread.isMainThread() {
            dispatch_async(dispatch_get_main_queue(), { [weak self] in
                self?.alert(withMessage: message)
                })
            return
        }
        
        var presenterViewController = window?.rootViewController
        
        while let presentedViewController = presenterViewController?.presentedViewController {
            presenterViewController = presentedViewController
        }
        
        if let presenterViewController = presenterViewController {
            let controller = UIAlertController(title: "Phoenix Demo", message: message, preferredStyle: .Alert)
            controller.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            presenterViewController.presentViewController(controller, animated: true, completion: nil)
        }
        else {
            print("Unable to raise alert: " + message)
        }
    }
    
    // MARK:- PhoenixDelegate
    
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

