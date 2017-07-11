//
//  AppDelegate.swift
//  Intelligence
//
//  Created by chethan.palaksha on 19/4/17.
//  Copyright © 2017 TigerSpike. All rights reserved.
//

import UIKit
import CoreLocation

import IntelligenceSDK

let IntelligenceDemoStoredDeviceTokenKey = "IntelligenceDemoStoredDeviceTokenKey"

extension AppDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            startupIntelligence()
        }
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, IntelligenceDelegate {
    
    var window: UIWindow?
    let locationManager: CLLocationManager = CLLocationManager()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        
        //        startupIntelligence()
        locationManager.delegate = self
        if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        }
        
        return true
    }
    
    func startupViewController() -> StartupViewController? {
        
        if let rootViewController = self.window?.rootViewController, rootViewController is StartupViewController {
            return rootViewController as? StartupViewController
        }
        else{
            return nil
        }
    }
    
    func segueToDemo()  {
        //self.window?.rootViewController?.performSegue(withIdentifier: "intelligenceStartedUp", sender: self)
    }
    
    func startupIntelligence() {
        if IntelligenceManager.intelligence != nil {
            return
        }
        
        self.startupViewController()?.state = .starting
        
        do {
            let intelligence = try Intelligence(withDelegate: self, file: "IntelligenceConfiguration")
//            intelligence.location.includeLocationInEvents = true
//            intelligence.IntelligenceLogger.enableLogging = true;
//            intelligence.IntelligenceLogger.logLevel = .debug;
            
            // Startup all modules.
            intelligence.startup { (success) -> () in
                
                OperationQueue.main.addOperation {
                    
                    if success {
                        
                        // Register test event.
                        let testEvent = Event(withType: "Intelligence.Test.Event.Type")
                        intelligence.analytics.track(event: testEvent)
                        IntelligenceManager.startup(with: intelligence)
                        
                        self.startupViewController()?.state = .started
                        self.registerForPush()
                        self.segueToDemo()
                    }
                    else {
                        self.startupViewController()?.state = .failed
                        
                        // Allow the user to retry to startup intelligence.
                        let message = "Intelligence was unable to initialise properly. This can lead to unexpected behaviour. Please restart the app to retry the Intelligence startup."
                        let controller = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
                        controller.addAction(UIAlertAction(title: "Retry", style: .cancel, handler: { (action) -> Void in
                            // Try again to start intelligence
                            self.startupIntelligence()
                        }))
                        
                        self.window?.rootViewController?.present(controller, animated: true, completion: nil)
                    }
                }
            }
        }
        catch IntelligenceSDK.ConfigurationError.fileNotFoundError {
            unrecoverableAlert(with: "The file you specified does not exist!")
        }
        catch IntelligenceSDK.ConfigurationError.invalidFileError {
            unrecoverableAlert(with: "The file is invalid! Check that the JSON provided is correct.")
        }
        catch IntelligenceSDK.ConfigurationError.missingPropertyError {
            unrecoverableAlert(with: "You missed a property!")
        }
        catch IntelligenceSDK.ConfigurationError.invalidPropertyError {
            unrecoverableAlert(with: "There is an invalid property!")
        }
        catch {
            unrecoverableAlert(with: "Treat the error with care!")
        }
    }
    
    func registerForPush() {
        let application = UIApplication.shared
        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: .alert, categories: nil))
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        IntelligenceManager.intelligence?.analytics.pause()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        IntelligenceManager.intelligence?.analytics.resume()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        IntelligenceManager.intelligence?.shutdown()
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        IntelligenceManager.intelligence?.identity.registerDeviceToken(with: deviceToken) { (tokenId, error) -> Void in
            if error != nil {
                self.alert(withMessage: "Failed with error: \(error!.code)")
            } else {
                // Store token id for unregistration. For this example I have stored it in user defaults.
                // However, this should be stored in the keychain as the app may be uninstalled and reinstalled
                // multiple times and may receive the same device token from Apple.
                UserDefaults.standard.set(tokenId, forKey: IntelligenceDemoStoredDeviceTokenKey)
                UserDefaults.standard.synchronize()
                
                self.alert(withMessage: "Registration Succeeded!")
            }
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        alert(withMessage: "Unable to Register for Push Notifications")
    }
    
    /// This method should only be called if there is a IntelligenceSDK.ConfigurationError during
    /// startup or if one of the INTIntelligenceDelegate methods is invoked after calling startup.
    /// This method will present an alert and put the app into an unrecoverable state.
    /// You will need to run the app again in order to try startup again.
    private func unrecoverableAlert(with message: String) {
        // Notify startup view controller of new state
        startupViewController()?.state = .failed
        // Present alert
        alert(withMessage: message)
    }
    
    func alert(withMessage message: String) {
        if !Thread.isMainThread {
            DispatchQueue.main.async(execute: { [weak self] in
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
                
                
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + .seconds(1), execute: {
                    [weak self] in
                    self?.alert(withMessage: message)
                })
                return
            }
            
            let controller = UIAlertController(title: "Intelligence Demo", message: message, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            presenterViewController.present(controller, animated: true, completion: nil)
        }
        else {
            print("Unable to raise alert: " + message)
        }
    }
    
    // MARK:- IntelligenceDelegate
    
    /// Credentials provided are incorrect. Will not distinguish between incorrect client or user credentials.
    func credentialsIncorrect(for intelligence:
        Intelligence) {
        unrecoverableAlert(with: "Unrecoverable error occurred during login, check credentials for Intelligence accounts.")
    }
    
    /// Account has been disabled and no longer active. Credentials are no longer valid.
    func accountDisabled(for intelligence: Intelligence) {
        unrecoverableAlert(with: "Unrecoverable error occurred during login, the Intelligence account is disabled.")
    }
    
    /// Account has failed to authentication multiple times and is now locked. Requires an administrator to unlock the account.
    func accountLocked(for intelligence: Intelligence) {
        unrecoverableAlert(with: "Unrecoverable error occurred during login, the Intelligence account is locked. Contact an Intelligence Administrator")
    }
    
    /// Token is invalid or expired, this may occur if your Application is configured incorrectly.
    func tokenInvalidOrExpired(for intelligence: Intelligence) {
        unrecoverableAlert(with: "Unrecoverable error occurred during user creation, check credentials for Intelligence accounts.")
    }
    
    /// Unable to create SDK user, this may occur if a user with the randomized credentials already exists (highly unlikely) or your Application is configured incorrectly and has the wrong permissions.
    func userCreationFailed(for intelligence: Intelligence) {
        unrecoverableAlert(with: "Unrecoverable error occurred during user creation, check Intelligence accounts are configured correctly.")
    }
    
    /// User is required to login again, developer must implement this method you may present a 'Login Screen' or silently call identity.login with stored credentials.
    func userLoginRequired(for intelligence: Intelligence) {
        // Present login screen or call identity.login with credentials stored in Keychain.
        unrecoverableAlert(with: "Token expired, you will need to login again.")
    }
    
    /// Unable to assign provided sdk_user_role to your newly created user. This may occur if the Application is configured incorrectly in the backend and doesn't have the correct permissions or the role doesn't exist.
    func userRoleAssignmentFailed(for intelligence: Intelligence) {
        unrecoverableAlert(with: "Unrecoverable error occurred during user role assignment, if this happens consistently please confirm that Intelligence accounts are configured correctly.")
    }
}

