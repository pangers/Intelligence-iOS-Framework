//
//  ViewUserViewController.swift
//  PhoenixDemo-Swift
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit

import PhoenixSDK

class ViewUserViewController : UIViewController {
    
    var fetchMe: Bool = false
    
    var user:Phoenix.User? {
        didSet {
            displayUser()
        }
    }
    var phoenix: Phoenix? {
        return PhoenixManager.manager.phoenix
    }
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var avatarURLLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    override func viewDidLoad() {
        displayUser()
        if fetchMe {
            phoenix?.identity.getMe(displayMe)
        }
    }
    
    func displayMe(user: Phoenix.User?, error: NSError?) {
        NSOperationQueue.mainQueue().addOperationWithBlock({ [weak self] in
            guard let user = user else {
                let alert = UIAlertController(title: "Error", message: error?.description ?? "Unknown error", preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Cancel, handler: nil))
                self?.presentViewController(alert, animated: true, completion: nil)
                return
            }
            self?.user = user
        })
    }
    
    func displayUser() {
        guard let user = self.user else {
            return
        }
        
        if userLabel == nil {
            return
        }
        
        if user.userId != 0 {
            idLabel.text = "User Id: \(user.userId)"
        }
        else {
            idLabel.text = "User Id: --"
        }
        
        let lastName = user.lastName ?? "N/A"
        let password = user.password ?? "N/A"
        let avatar = user.avatarURL ?? "N/A"
        
        userLabel.text = "Username: \(user.username)"
        passwordLabel.text = "Password: \(password)"
        avatarURLLabel.text = "AvatarURL: \(avatar)"
        firstNameLabel.text = "FirstName: \(user.firstName)"
        lastNameLabel.text = "LastName: \(lastName)"
    }
}