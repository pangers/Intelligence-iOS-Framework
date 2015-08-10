//
//  ViewUserViewController.swift
//  PhoenixDemo-Swift
//
//  Created by Josep Rodriguez on 03/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit

import PhoenixSDK

class ViewUserViewController : UIViewController, UISearchBarDelegate {
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var avatarURLLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var idLabel: UILabel!
    
    var user:Phoenix.User? {
        didSet {
            displayUser()
        }
    }
    
    var phoenix: Phoenix? {
        return PhoenixManager.manager.phoenix
    }
    
    override func viewDidLoad() {
        displayUser()
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
        
        let lastName = user.lastName ?? "N/A"
        let password = user.password ?? "N/A"
        let avatar = user.avatarURL ?? "N/A"
        
        NSOperationQueue.mainQueue().addOperation(NSBlockOperation(block: { () -> Void in
            if user.userId != 0 {
                self.idLabel.text = "User Id: \(user.userId)"
            }
            else {
                self.idLabel.text = "User Id: --"
            }

            self.userLabel.text = "Username: \(self.user?.username)"
            self.passwordLabel.text = "Password: \(password)"
            self.avatarURLLabel.text = "AvatarURL: \(avatar)"
            self.firstNameLabel.text = "FirstName: \(self.user?.firstName)"
            self.lastNameLabel.text = "LastName: \(lastName)"
            self.infoLabel.text = ""
        }))
    }
    
    // the beta 4 has an issue with empty labels in a stack layout, so use a space instead.
    func showInformation(information:String) {
        NSOperationQueue.mainQueue().addOperation(NSBlockOperation(block: { () -> Void in
            self.infoLabel.text = information ?? " "
        }))
    }
    
    // MARK:- UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        guard let userIdText = searchBar.text,
            let userId = Int(userIdText) else {
                showInformation("Couldn't get an integer from the user Id you typed")
                return
        }
        
        // clear info label
        self.infoLabel.text = ""
        searchBar.resignFirstResponder()
        
        // gets the user by its id and treats it in the callback.
        phoenix?.identity.getUser(userId) { (user, error) -> Void in
            if user != nil {
                self.user = user
            }
            else {
                self.showInformation("Error occured while loading user data: \(error)")
            }
        }
    }

}