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
            
            let dict:[String:AnyObject] = ["company.id.code":"TS Sing" as AnyObject]
            let event = Event(withType: eventType, value: eventValue,metadata:dict)
            IntelligenceManager.intelligence?.analytics.track(event: event)
            
        } else {
            let controller = UIAlertController(title: "Enter Values", message: "Enter Event Type and Event Value to trigger the event", preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func shutDownAnalytics(complition:@escaping(NSError?)->()) {
        IntelligenceManager.intelligence?.analytics.shutdown()
        complition(nil)
    }
    
    func pauseAnalytics(complition:@escaping(NSError?)->()) {
        IntelligenceManager.intelligence?.analytics.pause()
        complition(nil)
    }
    
    func resumeAnalytics(complition:@escaping(NSError?)->()) {
        IntelligenceManager.intelligence?.analytics.resume()
        complition(nil)
    }
    
    func startAnalytics(complition:@escaping(NSError?)->()) {
       
        IntelligenceManager.intelligence?.analytics.startup(completion: { (status) in
            print("Status --- %d",status)
        })
    }
    
    func sendEvent(name:String,targetId:String?, metaData:[String:AnyObject]?,complition:@escaping(NSError?)->())  {
        
      let event = Event(withType: name, value: 0.0, targetId: targetId, metadata: metaData)
    
      IntelligenceManager.intelligence?.analytics.track(event: event)
    }
    
  
}
