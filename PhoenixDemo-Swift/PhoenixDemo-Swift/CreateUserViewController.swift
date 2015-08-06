//
//  CreateUserViewController.swift
//  PhoenixDemo-Swift
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit

import PhoenixSDK

class CreateUserViewController : UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var avatarURL: UITextField!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var lastUserCreated:PhoenixUser?
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        spinner.hidden = true
    }
    
    @IBAction func didTapCreateUser(sender: AnyObject) {
        guard let usernameText = username.text,
            let passwordText = password.text,
            let firstNameText = firstName.text,
            let lastNameText = lastName.text,
            let avatarURLText = avatarURL.text
            where !usernameText.isEmpty && !passwordText.isEmpty && !firstNameText.isEmpty && !lastNameText.isEmpty && !avatarURLText.isEmpty else {
                
                createUserError("Some fields were not populated")
                return
        }

        showProgress(true)

        let user = Phoenix.User(companyId: PhoenixManager.manager.phoenix!.currentConfiguration.companyId, username: usernameText, password: passwordText, firstName: firstNameText, lastName: lastNameText, avatarURL: avatarURLText)
        
        PhoenixManager.manager.phoenix?.identity.createUser(user, callback: { [weak self] (user, error) -> Void in
            
            guard let this = self else {
                return
            }
            
            this.showProgress(false)
            
            this.lastUserCreated = user
            
            if let err = error {
                this.createUserError(err.description)
                return
            }
            
            guard let user = user else {
                assertionFailure("Should never get a user without an error")
                return
            }

            dispatch_async(dispatch_get_main_queue(), { [weak self] () -> Void in
                guard let this = self else {
                    return
                }
                
                let showUserAction = this.createShowUserActionWithUser(user)
                
                this.showAlert("User created", message: "Successfully created a user with Id \(user.userId)", extraAction:showUserAction)
            })
            
        })
    }
    
    func createUserError(message:String) {
        showAlert("Can't create user", message: message)
    }

    func showAlert(title:String, message:String, extraAction:UIAlertAction? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: { (UIAlertAction) -> Void in
            alertController.dismissViewControllerAnimated(true, completion:nil)
        }))
        
        if let action = extraAction {
            alertController.addAction(action)
        }
        
        self.presentViewController(alertController, animated: true, completion:nil)
    }

    func createShowUserActionWithUser(user:PhoenixUser) -> UIAlertAction {
        return UIAlertAction(title: "View user", style: .Default, handler: { [weak self] (UIAlertAction) -> Void in
            
            guard let this = self else {
                return
            }

            this.performSegueWithIdentifier("showUser", sender:self)
            
        })
    }
    
    func showProgress(show:Bool) {
        dispatch_async(dispatch_get_main_queue()) { [weak self] () -> Void in
            guard let this = self else {
                return
            }
            
            this.view.userInteractionEnabled = !show
            this.spinner.hidden = !show
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showUser" {
            let viewUserViewController = segue.destinationViewController as! ViewUserViewController
            viewUserViewController.user = lastUserCreated
        }
    }
}


