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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == ManageUserSegue {
            if let manageUser = segue.destination as? ManageUserViewController {
                manageUser.user = user
            }
        }
        else if segue.identifier == ViewUserSegue {
            if let viewUser = segue.destination as? ViewUserViewController {

                viewUser.user = user
            }
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        
        if indexPath.row == 0 {
            login()
        }
        else if indexPath.row == 1 {
            getUser()
        }
        else {
            let application = UIApplication.shared
            let delegate = application.delegate as! AppDelegate
            
            delegate.alert(withMessage: "Unexpected Row")
        }
    }
    
    func login() {
        let alert = UIAlertController(title: "Enter Details", message: nil, preferredStyle: UIAlertControllerStyle.alert)
        
        alert.addTextField { (textField) -> Void in
            textField.placeholder = "Username"
        }
        
        alert.addTextField { (textField) -> Void in
            textField.placeholder = "Password"
            textField.isSecureTextEntry = true
        }
        
        
        alert.addAction(UIAlertAction(title: "Login", style: UIAlertActionStyle.default, handler: { [weak self] (action) -> Void in
            guard let username = alert.textFields?.first?.text, let password = alert.textFields?.last?.text else {
                return
            }
            
            // logout before we login to clear the previous token (which means we check the login credentials, not just the token)
            IntelligenceManager.intelligence?.identity.logout()
            
            IntelligenceManager.intelligence?.identity.login(with: username, password: password, callback: { [weak self] (user, error) -> () in
                guard let strongSelf = self else {
                    return
                }
                
                DispatchQueue.main.async{

                    guard error == nil else {
                        let application = UIApplication.shared

                        let delegate = application.delegate as! AppDelegate
                        
                        delegate.alert(withMessage: "Login Failed")
                        
                        return
                    }
                    
                    strongSelf.user = user
                    strongSelf.performSegue(withIdentifier: strongSelf.ManageUserSegue, sender: strongSelf)
                }
                })
            }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            })
        present(alert, animated: true) { }
    }
    
    func getUser() {
        let alertController = UIAlertController(title: "Enter Details", message: nil, preferredStyle: .alert)
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "UserId"
        }
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            })
        
        alertController.addAction(UIAlertAction(title: "Get User", style: .default) { [weak self] (action) -> Void in
            
            guard let strongSelf = self,
                let userString = alertController.textFields?.first?.text,
                let

                userId = Int(userString) else {
                    return
            }
            
            IntelligenceManager.intelligence?.identity.getUser(with: userId, callback: { [weak strongSelf] (user, error) -> () in
                guard let strongSelf = strongSelf else {
                    return
                }

                DispatchQueue.main.async{
                    strongSelf.user = user
                    strongSelf.performSegue(withIdentifier: strongSelf.ViewUserSegue, sender: strongSelf)
                }
                })
            })
        
        present(alertController, animated: true) { }
    }
    
    @IBAction func unwindOnLogout(segue: UIStoryboardSegue) {
        
    }
}
