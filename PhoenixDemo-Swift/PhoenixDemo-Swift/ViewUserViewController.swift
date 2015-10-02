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
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var firstname: UITextField!
    @IBOutlet weak var lastname: UITextField!
    @IBOutlet weak var avatarURL: UITextField!
    
    var user:Phoenix.User? {
        didSet {
            displayUser()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayUser()
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "tappedScreen:"))
    }
    
    @objc func tappedScreen(tap: UITapGestureRecognizer) {
        let fields = [username, password, firstname, lastname, avatarURL]
        fields.forEach {
            if $0.isFirstResponder() {
                $0.resignFirstResponder()
            }
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
        guard let user = self.user else { return }
        NSOperationQueue.mainQueue().addOperation(NSBlockOperation(block: { () -> Void in
            if user.userId != 0 {
                self.idLabel.text = "User Id: \(user.userId)"
            }
            else {
                self.idLabel.text = "User Id: --"
            }
            self.idLabel.text = "\(self.user!.userId)"
            self.username.text = self.user!.username
            self.password.text = self.user!.password    // should be empty
            self.firstname.text = self.user!.firstName
            self.lastname.text = self.user!.lastName
            self.avatarURL.text = self.user!.avatarURL
        }))
    }
    
    @IBAction func updateUser() {
        guard let user = self.user else { return }
        user.username = username.text ?? ""
        user.password = password.text
        user.firstName = firstname.text ?? ""
        user.lastName = lastname.text
        user.avatarURL = avatarURL.text
        PhoenixManager.phoenix?.identity.updateUser(user, callback: { (user, error) -> Void in
            if let user = user {
                self.user = user
                self.showInformation(" ")
            } else if let error = error {
                self.showInformation("There was an error while getting the user: \(error)")
            }
        })
    }
    
    // the beta 4 has an issue with empty labels in a stack layout, so use a space instead.
    func showInformation(information:String) {
        NSOperationQueue.mainQueue().addOperation(NSBlockOperation(block: { () -> Void in
            self.infoLabel.text = information ?? " "
        }))
    }

}