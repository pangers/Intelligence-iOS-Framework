//
//  StartupViewController.swift
//  IntelligenceDemo-Swift
//
//  Created by Chris Nevin on 18/02/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import UIKit

enum StartupState {
    case Starting
    case Started
    case Failed
}

class StartupViewController : UIViewController {

    @IBOutlet weak var loadingLabel: UILabel?

    var state: StartupState = .Starting {
        didSet {
            switch (state) {
            case .Starting:
                loadingLabel?.text = "Wait while we startup Intelligence..."
            case .Started:
                performSegueWithIdentifier("intelligenceStartedUp", sender: self)
            case .Failed:
                loadingLabel?.text = "Unable to startup Intelligence."
            }
        }
    }


}
