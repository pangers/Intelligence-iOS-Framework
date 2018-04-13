//
//  AnalyticsCustomEventViewController.swift
//  IntelligenceDemo-Swift
//
//  Created by Shan Haq on 3/31/16.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

import UIKit
import IntelligenceSDK

class AnalyticsCustomEventViewController: UIViewController {

    @IBOutlet weak var txtEventType: UITextField!
    @IBOutlet weak var txtEventValue: UITextField!
    @IBOutlet weak var btnTriggerEvent: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnTriggerEventClicked(sender: AnyObject) {

        if let eventType = txtEventType.text, let eventValue = Double(txtEventValue.text ?? "0") {

            let dict: [String: AnyObject] = ["company":"TS Sing" as AnyObject]
            let event = Event(withType: eventType, value: eventValue, metadata: dict)
            IntelligenceManager.intelligence?.analytics.track(event: event)

        } else {
            let controller = UIAlertController(title: "Enter Values", message: "Enter Event Type and Event Value to trigger the event", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(controller, animated: true, completion: nil)
        }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
