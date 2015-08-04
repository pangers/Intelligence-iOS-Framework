//
//  AuthenticationViewController.swift
//  PhoenixDemo-Swift
//
//  Created by Chris Nevin on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit
import PhoenixSDK

class AuthenticationViewController: UITableViewController, PhoenixNetworkDelegate {
    
    // TODO: Refactor with PhoenixManager class in PSDK-35
    var phoenix: Phoenix?
    var loginErrorMessage: String?
    func rise() {
        do {
            let instance = try Phoenix(withFile: "PhoenixConfiguration")
            instance.networkDelegate = self
            instance.startup(withCallback: { (authenticated) -> () in
                print("Anonymous login \(authenticated)")
            })
            self.phoenix = instance
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
    
    func authenticationFailed(data: NSData?, response: NSURLResponse?, error: NSError?) {
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Authentication"
        rise()
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        if indexPath.row == 0 {
            if loginErrorMessage == nil {
                cell.textLabel?.text = self.phoenix?.isLoggedIn == true ? "Logged in" : "Login"
            } else {
                cell.textLabel?.text = loginErrorMessage
            }
            cell.userInteractionEnabled = self.phoenix?.isLoggedIn == false
        } else {
            cell.textLabel?.text = "Logout"
            cell.userInteractionEnabled = self.phoenix?.isLoggedIn == true
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 0 {
            login()
        } else {
            logout()
        }
    }
    
    func login() {
        if self.phoenix?.isLoggedIn == true { return }
        
        self.loginErrorMessage = "Logging in..."
        self.tableView.reloadData()
        
        let alert = UIAlertController(title: "Enter Details", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Username"
        }
        alert.addTextFieldWithConfigurationHandler { (textField) -> Void in
            textField.placeholder = "Password"
            textField.secureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "Login", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            guard let username = alert.textFields?.first?.text, password = alert.textFields?.last?.text else {
                return
            }
            self.phoenix?.login(withUsername: username, password: password, callback: { (authenticated) -> () in
                if !authenticated {
                    self.loginErrorMessage = "Login failed"
                } else {
                    self.loginErrorMessage = nil
                }
                NSOperationQueue.mainQueue().addOperationWithBlock() {
                    self.tableView.performSelector("reloadData", withObject: nil, afterDelay: 0.5)
                }
            })
        }))
        self.presentViewController(alert, animated: true) { }
    }
    
    func logout() {
        self.phoenix?.logout()
        self.tableView.reloadData()
    }
    
    
}