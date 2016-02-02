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
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        defer {
            if indexPath.row != 0 {
                tableView.deselectRowAtIndexPath(indexPath, animated: true)
            }
        }
        let application = UIApplication.sharedApplication()
        let delegate = application.delegate as! AppDelegate
        let tokenId = NSUserDefaults.standardUserDefaults().integerForKey(PhoenixDemoStoredDeviceTokenKey)
        if indexPath.row == 1 {
            if tokenId != 0 {
                delegate.alert(withMessage: "Already Registered!")
                return
            }
            
            application.registerForRemoteNotifications()
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert, categories: nil))
        } else if indexPath.row == 2 {
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