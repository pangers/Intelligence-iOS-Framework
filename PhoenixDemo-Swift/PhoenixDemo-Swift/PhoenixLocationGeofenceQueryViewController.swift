//
//  PhoenixLocationGeofenceQueryViewController.swift
//  PhoenixDemo-Swift
//
//  Created by Josep Rodriguez on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit
import PhoenixSDK

protocol GeofenceQueryBuilderDelegate {
    
    func didSelectGeofenceQuery(geofenceQuery:GeofenceQuery)
    
}

class PhoenixLocationGeofenceQueryViewController: UIViewController {

    @IBOutlet weak var latitudeText: UITextField!
    @IBOutlet weak var longitudeText: UITextField!
    @IBOutlet weak var pageSizeText: UITextField!
    @IBOutlet weak var pageText: UITextField!
    @IBOutlet weak var radiusText: UITextField!
    @IBOutlet weak var sortDirectionSegmentedControl: UISegmentedControl!
    
    var latitude:Double?
    var longitude:Double?
    var delegate:GeofenceQueryBuilderDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("didTapOnView")))
        
        self.latitudeText.text = latitude != nil ? String(latitude!) : ""
        self.longitudeText.text = longitude != nil ? String(longitude!) : ""
    }
    
    func didTapOnView() {
        [latitudeText, longitudeText, pageSizeText, pageText, radiusText].forEach{
            $0.resignFirstResponder()
        }
    }
    
    @IBAction func didTapSave(sender: AnyObject) {
        let query = GeofenceQuery(location: PhoenixCoordinate(withLatitude: Double(latitudeText.text ?? "0") ?? 0, longitude: Double(longitudeText.text ?? "0") ?? 0))
        query.radius = Double(radiusText.text ?? "1000")
        query.pageSize = Int(pageSizeText.text ?? "10")
        query.pageNumber = Int(pageText.text ?? "1")
        query.sortingDirection = sortDirectionSegmentedControl.selectedSegmentIndex == 1 ? .Ascending : .Descending

        delegate?.didSelectGeofenceQuery(query)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapCancel(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}
