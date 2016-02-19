//
//  AppDelegate.swift
//  IntelligenceDemo-Swift
//
//  Created by Rui Silvestre on 20/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit

import IntelligenceSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, IntelligenceDelegate {

    var window: UIWindow?

    var startupViewController: StartupViewController? {
        return self.window?.rootViewController as? StartupViewController
    }

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        startupIntelligence()

        return true
    }

    func startupIntelligence() {
        if IntelligenceManager.intelligence != nil {
            return
        }

        startupViewController?.state = .Starting

        do {
            let intelligence = try Intelligence(withDelegate: self, file: "IntelligenceConfiguration")

            // Startup all modules.
            intelligence.startup { (success) -> () in

                NSOperationQueue.mainQueue().addOperationWithBlock {

                    if success {
                        // Register test event.
                        let testEvent = Event(withType: "Intelligence.Test.Event.Type")
                        intelligence.analytics.track(testEvent)
                        IntelligenceManager.startupWithIntelligence(intelligence)

                        self.startupViewController?.state = .Started
                    }
                    else {
                        self.startupViewController?.state = .Failed

                        // Allow the user to retry to startup intelligence.
                        let message = "Intelligence was unable to initialise properly. This can lead to unexpected behaviour. Please restart the app to retry the Intelligence startup."
                        let controller = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
                        controller.addAction(UIAlertAction(title: "Retry", style: .Cancel, handler: { (action) -> Void in
                            // Try again to start intelligence
                            self.startupIntelligence()
                        }))

                        self.window?.rootViewController?.presentViewController(controller, animated: true, completion: nil)
                    }
                }
            }
        }
        catch IntelligenceSDK.ConfigurationError.FileNotFoundError {
            unrecoverableAlert(withMessage: "The file you specified does not exist!")
        }
        catch IntelligenceSDK.ConfigurationError.InvalidFileError {
            unrecoverableAlert(withMessage: "The file is invalid! Check that the JSON provided is correct.")
        }
        catch IntelligenceSDK.ConfigurationError.MissingPropertyError {
            unrecoverableAlert(withMessage: "You missed a property!")
        }
        catch IntelligenceSDK.ConfigurationError.InvalidPropertyError {
            unrecoverableAlert(withMessage: "There is an invalid property!")
        }
        catch {
            unrecoverableAlert(withMessage: "Treat the error with care!")
        }
    }

	func applicationDidEnterBackground(application: UIApplication) {
        IntelligenceManager.intelligence?.analytics.pause()
	}

	func applicationWillEnterForeground(application: UIApplication) {
        IntelligenceManager.intelligence?.analytics.resume()
	}

	func applicationWillTerminate(application: UIApplication) {
        IntelligenceManager.intelligence?.shutdown()
	}

    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        IntelligenceManager.intelligence?.identity.registerDeviceToken(deviceToken) { (tokenId, error) -> Void in
            if error != nil {
                self.alert(withMessage: "Failed with error: \(error!.code)")
            } else {
                // Store token id for unregistration. For this example I have stored it in user defaults.
                // However, this should be stored in the keychain as the app may be uninstalled and reinstalled
                // multiple times and may receive the same device token from Apple.
                NSUserDefaults.standardUserDefaults().setInteger(tokenId, forKey: IntelligenceDemoStoredDeviceTokenKey)
                NSUserDefaults.standardUserDefaults().synchronize()

                self.alert(withMessage: "Registration Succeeded!")
            }
        }
    }

    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        alert(withMessage: "Unable to Register for Push Notifications")
    }

    /// This method should only be called if there is a IntelligenceSDK.ConfigurationError during
    /// startup or if one of the INTIntelligenceDelegate methods is invoked after calling startup.
    /// This method will present an alert and put the app into an unrecoverable state.
    /// You will need to run the app again in order to try startup again.
    private func unrecoverableAlert(withMessage message: String) {
        // Notify startup view controller of new state
        startupViewController?.state = .Failed
        // Present alert
        alert(withMessage: message)
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
            guard let _ = presenterViewController.view.window else {
                // presenterViewController in not yet atttached to the window
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), { [weak self] in
                    self?.alert(withMessage: message)
                    })
                return
            }

            let controller = UIAlertController(title: "Intelligence Demo", message: message, preferredStyle: .Alert)
            controller.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
            presenterViewController.presentViewController(controller, animated: true, completion: nil)
        }
        else {
            print("Unable to raise alert: " + message)
        }
    }

    // MARK:- IntelligenceDelegate

    /// Credentials provided are incorrect. Will not distinguish between incorrect client or user credentials.
    func credentialsIncorrectForIntelligence(intelligence: Intelligence) {
        unrecoverableAlert(withMessage: "Unrecoverable error occurred during login, check credentials for Intelligence accounts.")
    }

    /// Account has been disabled and no longer active. Credentials are no longer valid.
    func accountDisabledForIntelligence(intelligence: Intelligence) {
        unrecoverableAlert(withMessage: "Unrecoverable error occurred during login, the Intelligence account is disabled.")
    }

    /// Account has failed to authentication multiple times and is now locked. Requires an administrator to unlock the account.
    func accountLockedForIntelligence(intelligence: Intelligence) {
        unrecoverableAlert(withMessage: "Unrecoverable error occurred during login, the Intelligence account is locked. Contact an Intelligence Administrator")
    }
    
    /// Token is invalid or expired, this may occur if your Application is configured incorrectly.
    func tokenInvalidOrExpiredForIntelligence(intelligence: Intelligence) {
        unrecoverableAlert(withMessage: "Unrecoverable error occurred during user creation, check credentials for Intelligence accounts.")
    }

    /// Unable to create SDK user, this may occur if a user with the randomized credentials already exists (highly unlikely) or your Application is configured incorrectly and has the wrong permissions.
    func userCreationFailedForIntelligence(intelligence: Intelligence) {
        unrecoverableAlert(withMessage: "Unrecoverable error occurred during user creation, check Intelligence accounts are configured correctly.")
    }
    
    /// User is required to login again, developer must implement this method you may present a 'Login Screen' or silently call identity.login with stored credentials.
    func userLoginRequiredForIntelligence(intelligence: Intelligence) {
        // Present login screen or call identity.login with credentials stored in Keychain.
        unrecoverableAlert(withMessage: "Token expired, you will need to login again.")
    }

    /// Unable to assign provided sdk_user_role to your newly created user. This may occur if the Application is configured incorrectly in the backend and doesn't have the correct permissions or the role doesn't exist.
    func userRoleAssignmentFailedForIntelligence(intelligence: Intelligence) {
        unrecoverableAlert(withMessage: "Unrecoverable error occurred during user role assignment, if this happens consistently please confirm that Intelligence accounts are configured correctly.")
    }
}

