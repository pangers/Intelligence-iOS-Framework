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


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == UpdateUserSegue {
            if let updateUser = segue.destination as? ViewUserViewController {
                updateUser.user = user
            }
        }
        else if segue.identifier == UnwindOnLogoutSegue {
            
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }

        let application = UIApplication.shared
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
        let application = UIApplication.shared
        
        let tokenId = UserDefaults.standard.integer(forKey: IntelligenceDemoStoredDeviceTokenKey)
        
        if tokenId != 0 {
            let delegate = application.delegate as! AppDelegate
            delegate.alert(withMessage: "Already Registered!")
            return
        }
        
        application.registerForRemoteNotifications()
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: .alert, categories: nil))
    }
    
    func unregisterDeviceToken() {
        let application = UIApplication.shared
        let delegate = application.delegate as! AppDelegate
        
        let tokenId = UserDefaults.standard.integer(forKey: IntelligenceDemoStoredDeviceTokenKey)
        
        if tokenId == 0 {
            delegate.alert(withMessage: "Not Registered!")
            return
        }
        
        IntelligenceManager.intelligence?.identity.unregisterDeviceToken(with: tokenId, callback: { (error) -> Void in
            let notRegisteredError = error?.code == IdentityError.deviceTokenNotRegisteredError.rawValue
            
            if error != nil && !notRegisteredError {
                delegate.alert(withMessage: "Failed with error: \(error!.code)")
            }
            else {
                UserDefaults.standard.removeObject(forKey: IntelligenceDemoStoredDeviceTokenKey)
                UserDefaults.standard.synchronize()
                
                delegate.alert(withMessage: "Unregister Succeeded!")
            }
        })
    }
    
    func assignRole() {
//        let alertController = UIAlertController(title: "Enter Details", message: nil, preferredStyle: .alert)
//        
//        alertController.addTextField { (textField) -> Void in
//            textField.placeholder = "RoleId"
//        }
//        
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
//            })
//        
//        alertController.addAction(UIAlertAction(title: "Assign Role", style: .default) { [weak self] (action) -> Void in
//            
//            guard let strongSelf = self,
//                let roleString = alertController.textFields?.first?.text,
//                let roleId = Int(roleString) else {
//                    return
//            }
//            
//            IntelligenceManager.intelligence?.identity.assignRole(to: roleId, user: strongSelf.user!) { (user, error) -> Void in
//                DispatchQueue.main.async{
//                    let application = UIApplication.shared
//                    let delegate = application.delegate as! AppDelegate
//                    
//                    if let error = error {
//                        delegate.alert(withMessage: "Failed with error: \(error.code)")
//                    }
//                    else {
//                        delegate.alert(withMessage: "Role Assigned!")
//                    }
//                }
//            }
//            })
//        
//        present(alertController, animated: true) { }
    }
    
    func revokeRole() {
        
//        let alertController = UIAlertController(title: "Enter Details", message: nil, preferredStyle: .alert)
//        
//        alertController.addTextField { (textField) -> Void in
//            textField.placeholder = "RoleId"
//        }
//        
//        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
//            })
//        
//        alertController.addAction(UIAlertAction(title: "Revoke Role", style: .default) { [weak self] (action) -> Void in
//            
//            guard let strongSelf = self,
//                let roleString = alertController.textFields?.first?.text,
//                let roleId = Int(roleString) else {
//                    return
//            }
//            
//            IntelligenceManager.intelligence?.identity.revokeRole(with: roleId, user: strongSelf.user!) { (user, error) -> Void in
//                DispatchQueue.main.async{
//                    let application = UIApplication.shared
//                    let delegate = application.delegate as! AppDelegate
//                    
//                    if let error = error {
//                        delegate.alert(withMessage: "Failed with error: \(error.code)")
//                    }
//                    else {
//                        delegate.alert(withMessage: "Role Revoked!")
//                    }
//                }
//            }
//        })
//        
//        present(alertController, animated: true) { }
    }
    
    func logout() {
        IntelligenceManager.intelligence?.identity.logout()
        
        self.user = nil
        
        UserDefaults.standard.removeObject(forKey: IntelligenceDemoStoredDeviceTokenKey)
        UserDefaults.standard.synchronize()
        
        self.performSegue(withIdentifier: UnwindOnLogoutSegue, sender: self)
    }
}
