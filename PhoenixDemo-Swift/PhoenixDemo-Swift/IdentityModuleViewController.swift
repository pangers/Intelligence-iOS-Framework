//
//  IdentityModuleViewController.swift
//  PhoenixDemo-Swift
//
//  Created by Chris Nevin on 05/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit
import PhoenixSDK

let PhoenixDemoStoredDeviceTokenKey = "PhoenixDemoStoredDeviceTokenKey"

class IdentityModuleViewController : UITableViewController {
    
    private let ViewUserSegue = "GetAndViewUser"
    
    private var user: Phoenix.User? = nil
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ViewUserSegue {
            if let viewUser = segue.destinationViewController as? ViewUserViewController {
                viewUser.user = user
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        defer {
            if indexPath.row != 0 {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
        if indexPath.row == 1 {
            let alertController = UIAlertController(title: "Enter Details", message: nil, preferredStyle: .Alert)
            
            alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
                textField.placeholder = "UserId"
            }
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
                })
            
            alertController.addAction(UIAlertAction(title: "Get User", style: .Default) { [weak self] (action) -> Void in
                
                guard let strongSelf = self,
                    userString = alertController.textFields?.first?.text,
                    userId = Int(userString) else {
                    return
                }
                
                PhoenixManager.phoenix.identity.getUser(userId, callback: { [weak strongSelf] (user, error) -> () in
                    dispatch_async(dispatch_get_main_queue()) {
                        guard let strongSelf = strongSelf else {
                            return
                        }
                        
                        strongSelf.user = user
                        strongSelf.performSegueWithIdentifier(strongSelf.ViewUserSegue, sender: strongSelf)
                    }
                    })
                })
            
            presentViewController(alertController, animated: true) { }
                
            return
        }
        
        let application = UIApplication.sharedApplication()
        let delegate = application.delegate as! AppDelegate
        let tokenId = NSUserDefaults.standardUserDefaults().integerForKey(PhoenixDemoStoredDeviceTokenKey)
        if indexPath.row == 2 {
            if tokenId != 0 {
                delegate.alert(withMessage: "Already Registered!")
                return
            }
            
            application.registerForRemoteNotifications()
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert, categories: nil))
        } else if indexPath.row == 3 {
            // This method will return zero if unset.
            if tokenId == 0 {
                delegate.alert(withMessage: "Not Registered!")
                return
            }
            PhoenixManager.phoenix.identity.unregisterDeviceToken(withId: tokenId, callback: { (error) -> Void in
                let notRegisteredError = error?.code == IdentityError.DeviceTokenNotRegisteredError.rawValue
                if error != nil && !notRegisteredError {
                    delegate.alert(withMessage: "Failed with error: \(error!.code)")
                } else {
                    NSUserDefaults.standardUserDefaults().removeObjectForKey(PhoenixDemoStoredDeviceTokenKey)
                    NSUserDefaults.standardUserDefaults().synchronize()
                    delegate.alert(withMessage: "Unregister Succeeded!")
                }
            })
        }
    }
    
}