//
//  StartupViewController.swift
//  IntelligenceDemo-Swift
//
//  Created by Chris Nevin on 18/02/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import UIKit

enum StartupState {
    case starting
    case started
    case failed
}

class StartupViewController : UIViewController {

    @IBOutlet weak var loadingLabel: UILabel?

    var state: StartupState = .starting {
        didSet {
            switch (state) {
            case .starting:
                loadingLabel?.text = "Wait while we startup Intelligence..."
            case .started:
                performSegue(withIdentifier: "intelligenceStartedUp", sender: self)
            case .failed:
                loadingLabel?.text = "Unable to startup Intelligence."
            }
        }
    }


}
