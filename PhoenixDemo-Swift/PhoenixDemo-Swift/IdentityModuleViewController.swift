//
//  IdentityModuleViewController.swift
//  IntelligenceDemo-Swift
//
//  Created by Chris Nevin on 05/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit
import IntelligenceSDK

let IntelligenceDemoStoredDeviceTokenKey = "IntelligenceDemoStoredDeviceTokenKey"

class IdentityModuleViewController : UITableViewController {
    
    private let ManageUserSegue = "ManageUser"
    private let ViewUserSegue = "ViewUser"
    
    private var user: Intelligence.User? = nil
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ManageUserSegue {
            if let manageUser = segue.destinationViewController as? ManageUserViewController {
                manageUser.user = user
            }
        }
        else if segue.identifier == ViewUserSegue {
            if let viewUser = segue.destinationViewController as? ViewUserViewController {
                viewUser.user = user
            }
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        defer {
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        if indexPath.row == 0 {
            login()
        }
        else if indexPath.row == 1 {
            getUser()
        }
        else {
            let application = UIApplication.sharedApplication()
            let delegate = application.delegate as! AppDelegate
            
            delegate.alert(withMessage: "Unexpected Row")
        }
    }
    
    func login() {
        let alert = UIAlertController(title: "Enter Details", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Username"
        }
        
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
        }
        
        
        alert.addAction(UIAlertAction(title: "Login", style: UIAlertActionStyle.Default, handler: { [weak self] (action) -> Void in
            guard let username = alert.textFields?.first?.text, password = alert.textFields?.last?.text else {
                return
            }
            
            IntelligenceManager.intelligence.identity.login(withUsername: username, password: password, callback: { [weak self] (user, error) -> () in
                guard let strongSelf = self else {
                    return
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    guard error == nil else {
                        let application = UIApplication.sharedApplication()
                        let delegate = application.delegate as! AppDelegate
                        
                        delegate.alert(withMessage: "Login Failed")
                        
                        return
                    }
                    
                    strongSelf.user = user
                    strongSelf.performSegueWithIdentifier(strongSelf.ManageUserSegue, sender: strongSelf)
                }
                })
            }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            })
        presentViewController(alert, animated: true) { }
    }
    
    func getUser() {
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
            
            IntelligenceManager.intelligence.identity.getUser(userId, callback: { [weak strongSelf] (user, error) -> () in
                guard let strongSelf = strongSelf else {
                    return
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    strongSelf.user = user
                    strongSelf.performSegueWithIdentifier(strongSelf.ViewUserSegue, sender: strongSelf)
                }
                })
            })
        
        presentViewController(alertController, animated: true) { }
    }
    
    @IBAction func unwindOnLogout(segue: UIStoryboardSegue) {
        
    }
}
