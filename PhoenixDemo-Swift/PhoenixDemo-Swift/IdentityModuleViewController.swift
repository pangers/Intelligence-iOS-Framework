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
        let application = UIApplication.sharedApplication()
        let delegate = application.delegate as! AppDelegate
        if indexPath.row == 1 {
            application.registerForRemoteNotifications()
            application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert, categories: nil))
        } else if indexPath.row == 2 {
            // This method will return zero if unset.
            let tokenId = NSUserDefaults.standardUserDefaults().integerForKey(PhoenixDemoStoredDeviceTokenKey)
            if tokenId == 0 {
                delegate.alert(withMessage: "Not Registered!")
                return
            }
            PhoenixManager.phoenix.identity.unregisterDeviceToken(withId: tokenId, callback: { (error) -> Void in
                if error != nil {
                    delegate.alert(withError: error!)
                } else {
                    delegate.alert(withMessage: "Unregister Succeeded!")
                    NSUserDefaults.standardUserDefaults().removeObjectForKey(PhoenixDemoStoredDeviceTokenKey)
                    NSUserDefaults.standardUserDefaults().synchronize()
                }
            })
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}