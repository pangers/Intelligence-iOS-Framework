//
//  ManageUserViewController.swift
//  IntelligenceDemo-Swift
//
//  Created by Michael Lake on 09/02/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import UIKit
import IntelligenceSDK

class ManageUserViewController : UITableViewController {
    private let UpdateUserSegue = "UpdateUser"
    private let UnwindOnLogoutSegue = "UnwindOnLogout"
    
    var user: Intelligence.User? = nil
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == UpdateUserSegue {
            if let updateUser = segue.destinationViewController as? ViewUserViewController {
                updateUser.user = user
            }
        }
        else if segue.identifier == UnwindOnLogoutSegue {
            
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        defer {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        let application = UIApplication.sharedApplication()
        let delegate = application.delegate as! AppDelegate
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                registerDeviceToken()
            }
            else if indexPath.row == 1 {
                unregisterDeviceToken()
            }
            else {
                delegate.alert(withMessage: "Unexpected Row")
            }
        }
        else if indexPath.section == 1 {
            if indexPath.row == 0 {
                assignRole()
            }
            else if indexPath.row == 1 {
                revokeRole()
            }
            else {
                delegate.alert(withMessage: "Unexpected Row")
            }
        }
        else if indexPath.section == 2 {
            if indexPath.row == 0 {
                // Segue in IB will handle this
            }
            else {
                delegate.alert(withMessage: "Unexpected Row")
            }
        }
        else if indexPath.section == 3 {
            if indexPath.row == 0 {
                logout()
            }
            else {
                delegate.alert(withMessage: "Unexpected Row")
            }
        }
        else {
            delegate.alert(withMessage: "Unexpected Section")
        }
    }
    
    func registerDeviceToken() {
        let application = UIApplication.sharedApplication()
        
        let tokenId = NSUserDefaults.standardUserDefaults().integerForKey(IntelligenceDemoStoredDeviceTokenKey)
        
        if tokenId != 0 {
            let delegate = application.delegate as! AppDelegate
            delegate.alert(withMessage: "Already Registered!")
            return
        }
        
        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: .Alert, categories: nil))
    }
    
    func unregisterDeviceToken() {
        let application = UIApplication.sharedApplication()
        let delegate = application.delegate as! AppDelegate
        
        let tokenId = NSUserDefaults.standardUserDefaults().integerForKey(IntelligenceDemoStoredDeviceTokenKey)
        
        if tokenId == 0 {
            delegate.alert(withMessage: "Not Registered!")
            return
        }
        
        IntelligenceManager.intelligence.identity.unregisterDeviceToken(withId: tokenId, callback: { (error) -> Void in
            let notRegisteredError = error?.code == IdentityError.DeviceTokenNotRegisteredError.rawValue
            
            if error != nil && !notRegisteredError {
                delegate.alert(withMessage: "Failed with error: \(error!.code)")
            }
            else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(IntelligenceDemoStoredDeviceTokenKey)
                NSUserDefaults.standardUserDefaults().synchronize()
                
                delegate.alert(withMessage: "Unregister Succeeded!")
            }
        })
    }
    
    func assignRole() {
        let alertController = UIAlertController(title: "Enter Details", message: nil, preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "RoleId"
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            })
        
        alertController.addAction(UIAlertAction(title: "Assign Role", style: .Default) { [weak self] (action) -> Void in
            
            guard let strongSelf = self,
                roleString = alertController.textFields?.first?.text,
                roleId = Int(roleString) else {
                    return
            }
            
            IntelligenceManager.intelligence.identity.assignRole(roleId, user: strongSelf.user!) { (user, error) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    let application = UIApplication.sharedApplication()
                    let delegate = application.delegate as! AppDelegate
                    
                    if let error = error {
                        delegate.alert(withMessage: "Failed with error: \(error.code)")
                    }
                    else {
                        delegate.alert(withMessage: "Role Assigned!")
                    }
                }
            }
            })
        
        presentViewController(alertController, animated: true) { }
    }
    
    func revokeRole() {
        let alertController = UIAlertController(title: "Enter Details", message: nil, preferredStyle: .Alert)
        
        alertController.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "RoleId"
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            })
        
        alertController.addAction(UIAlertAction(title: "Revoke Role", style: .Default) { [weak self] (action) -> Void in
            
            guard let strongSelf = self,
                roleString = alertController.textFields?.first?.text,
                roleId = Int(roleString) else {
                    return
            }
            
            IntelligenceManager.intelligence.identity.revokeRole(roleId, user: strongSelf.user!) { (user, error) -> Void in
                dispatch_async(dispatch_get_main_queue()) {
                    let application = UIApplication.sharedApplication()
                    let delegate = application.delegate as! AppDelegate
                    
                    if let error = error {
                        delegate.alert(withMessage: "Failed with error: \(error.code)")
                    }
                    else {
                        delegate.alert(withMessage: "Role Revoked!")
                    }
                }
            }
        })
        
        presentViewController(alertController, animated: true) { }
    }
    
    func logout() {
        IntelligenceManager.intelligence.identity.logout()
        
        self.user = nil
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey(IntelligenceDemoStoredDeviceTokenKey)
        NSUserDefaults.standardUserDefaults().synchronize()
        
        self.performSegueWithIdentifier(UnwindOnLogoutSegue, sender: self)
    }
}
