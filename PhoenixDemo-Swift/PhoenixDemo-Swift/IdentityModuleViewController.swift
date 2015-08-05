//
//  IdentityModuleViewController.swift
//  PhoenixDemo-Swift
//
//  Created by Chris Nevin on 05/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit

class IdentityModuleViewController : UITableViewController {
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // If we are presenting `GetMe` segue, set `fetchMe` to true.
        if segue.identifier == "GetMe" {
            (segue.destinationViewController as? ViewUserViewController)?.fetchMe = true
        }
    }
}