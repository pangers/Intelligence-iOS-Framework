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
    
    var user:PhoenixUser? {
        didSet {
            displayUser()
        }
    }
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var avatarURLLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    override func viewDidLoad() {
        displayUser()
    }
    
    func displayUser() {
        guard let user = self.user else {
            return
        }
        
        if userLabel == nil {
            return
        }
        
        if let userId = user.userId {
            idLabel.text = "User Id: \(userId)"
        }
        else {
            idLabel.text = "User Id: --"
        }
        
        userLabel.text = "Username: \(user.username)"
        passwordLabel.text = "Password: \(user.password)"
        avatarURLLabel.text = "AvatarURL: \(user.avatarURL)"
        firstNameLabel.text = "FirstName: \(user.firstName)"
        lastNameLabel.text = "LastName: \(user.lastName)"
    }
}