//
//  AuthenticationViewController.swift
//  PhoenixDemo-Swift
//
//  Created by Chris Nevin on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit
import PhoenixSDK

class AuthenticationViewController: UITableViewController {
    
    // Valid messages
    private enum LoginMessages: String {
        case None = ""
        case LoggedIn = "Logged in"
        case LoggingIn = "Logging in..."
        case Login = "Login"
        case LoginFailed = "Login Failed"
        func color() -> UIColor {
            switch self {
            case .LoggedIn: return .grayColor()
            case .LoginFailed: return .redColor()
            case .LoggingIn: return .purpleColor()
            default: return .blackColor()
            }
        }
    }
    
    private var loggedInUser: Phoenix.User?
    private var _loginMessage = LoginMessages.Login
    private var loginMessage: LoginMessages {
        get {
            return loggedIn ? .LoggedIn : _loginMessage
        }
        set {
            _loginMessage = newValue
        }
    }
    private var loggedIn: Bool {
        return phoenix?.identity.loggedIn == true
    }
    private var phoenix: Phoenix? {
        return PhoenixManager.manager.phoenix
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Authentication"
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "LoginViewUser" {
            if let viewUser = segue.destinationViewController as? ViewUserViewController {
                viewUser.user = loggedInUser
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
            cell.textLabel?.text = loginMessage.rawValue
            cell.textLabel?.textColor = loginMessage.color()
            cell.userInteractionEnabled = !loggedIn
        } else {
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
        if loggedIn { return }

        func reloadUI(message: LoginMessages) {
            loginMessage = message
            if NSThread.isMainThread() {
                tableView.reloadData()
            } else {
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
            self?.phoenix?.identity.login(withUsername: username, password: password, callback: { (user, error) -> () in
                reloadUI(self?.loggedIn == true ? .LoggedIn : .LoginFailed)
                if self?.loginMessage == .LoggedIn {
                    self?.loggedInUser = user
                    NSOperationQueue.mainQueue().addOperationWithBlock() { [weak self] in
                        self?.performSegueWithIdentifier("LoginViewUser", sender: self)
                    }
                }
            })
        }))
        presentViewController(alert, animated: true) { }
    }
    
    func logout() {
        loginMessage = .Login
        phoenix?.identity.logout()
        tableView.reloadData()
    }
}