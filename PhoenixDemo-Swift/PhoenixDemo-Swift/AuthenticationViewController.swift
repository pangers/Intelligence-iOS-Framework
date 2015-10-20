//
//  AuthenticationViewController.swift
//  PhoenixDemo-Swift
//
//  Created by Chris Nevin on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit
import PhoenixSDK

// Valid messages
private enum LoginMessage: String {
    case None = ""
    case LoggedIn = "Logged in"
    case LoggingIn = "Logging in..."
    case Login = "Login"
    case LoginFailed = "Login Failed"
    
    func color() -> UIColor {
        switch self {
        case .LoggedIn:
            return .grayColor()
            
        case .LoginFailed:
            return .redColor()
            
        case .LoggingIn:
            return .purpleColor()
            
        default:
            return .blackColor()
        }
    }
}

class AuthenticationViewController: UITableViewController {

    // Store your user login status. In this demo we just use a static variable for it.
    private static var loggedInUser: Phoenix.User?
    private static var loginMessage: LoginMessage = .Login

    private var loggedIn:Bool {
        return self.dynamicType.loginMessage == .LoggedIn
    }
    
    private let ViewUserSegue = "LoginViewUser"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Authentication"
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == ViewUserSegue {
            if let viewUser = segue.destinationViewController as? ViewUserViewController {
                viewUser.user = self.dynamicType.loggedInUser
            }
        }
    }
    
    // MARK:- UITableViewDataSource
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        if indexPath.row == 0 {
            cell.textLabel?.text = self.dynamicType.loginMessage.rawValue
            cell.textLabel?.textColor = self.dynamicType.loginMessage.color()
            cell.userInteractionEnabled = !loggedIn
        }
        else {
            cell.textLabel?.text = "Logout"
            cell.userInteractionEnabled = loggedIn
            cell.textLabel?.textColor = loggedIn ? .blackColor() : .grayColor()
        }
        
        return cell
    }
    
    // MARK:- UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 0 {
            login()
        } else {
            logout()
        }
    }
    
    // MARK:- Log in/out
    
    func login() {
        if loggedIn {
            return
        }

        func reloadUI(message: LoginMessage) {
            self.dynamicType.loginMessage = message
            if NSThread.isMainThread() {
                tableView.reloadData()
            }
            else {
                NSOperationQueue.mainQueue().addOperationWithBlock() { [weak self] in
                    self?.tableView.reloadData()
                }
            }
        }
        reloadUI(.LoggingIn)
        
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
                reloadUI(.Login)
                return
            }
            
            PhoenixManager.phoenix.identity.login(withUsername: username, password: password, callback: { [weak self] (user, error) -> () in
                reloadUI(error == nil ? .LoggedIn : .LoginFailed)
                
                if self?.dynamicType.loginMessage == .LoggedIn {
                    self?.dynamicType.loggedInUser = user
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock() { [weak self] in
                        self?.performSegueWithIdentifier(ViewUserSegue, sender: self)
                    }
                }
            })
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel) { (action) -> Void in
            reloadUI(.Login)
        })
        presentViewController(alert, animated: true) { }
    }
    
    func logout() {
        self.dynamicType.loginMessage = .Login
        PhoenixManager.phoenix.identity.logout()
        tableView.reloadData()
    }
}