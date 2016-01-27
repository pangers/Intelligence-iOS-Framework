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

    // MARK:- IBOutlets
    @IBOutlet weak var latitudeText: UITextField!
    @IBOutlet weak var longitudeText: UITextField!
    @IBOutlet weak var pageSizeText: UITextField!
    @IBOutlet weak var pageText: UITextField!
    @IBOutlet weak var radiusText: UITextField!
    
    @IBOutlet var accessoryView: UIView!

    // MARK:- Properties
    var latitude:Double?
    var longitude:Double?
    var delegate:GeofenceQueryBuilderDelegate?
    
    // MARK:- ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("resignResponders")))
        
        self.latitudeText.text = latitude != nil ? String(latitude!) : ""
        self.longitudeText.text = longitude != nil ? String(longitude!) : ""
        
        // Set accessory view to all texts:
        [latitudeText, longitudeText, pageSizeText, pageText, radiusText].forEach {
            $0.inputAccessoryView = accessoryView
        }
    }
    
    func resignResponders() {
        [latitudeText, longitudeText, pageSizeText, pageText, radiusText].forEach{
            $0.resignFirstResponder()
        }
    }
    
    // MARK:- IBActions
    
    @IBAction func didTapSave(sender: AnyObject) {
        resignResponders()
        
        let latitude : Double
        
        if let latitudeFromText = Double(latitudeText.text!) where latitudeText.text?.characters.count > 0 {
            latitude = latitudeFromText
        }
        else {
            latitude = 0
        }
        
        
        let longitude : Double
        
        if let longitudeFromText = Double(longitudeText.text!) where longitudeText.text?.characters.count > 0 {
            longitude = longitudeFromText
        }
        else {
            longitude = 0
        }
        
        
        let radius : Double
        
        if let radiusFromText = Double(radiusText.text!) where radiusText.text?.characters.count > 0 {
            radius = radiusFromText
        }
        else {
            radius = 40_075_000 // The circumference of the Earth
        }
        
        
        let query = GeofenceQuery(location: Coordinate(withLatitude: latitude, longitude: longitude),
            radius: radius)
        query.pageSize = pageSizeText.text?.characters.count > 0 ? Int(pageSizeText.text!) : nil
        query.pageNumber = pageText.text?.characters.count > 0 ? Int(pageText.text!) : nil
            
        delegate?.didSelectGeofenceQuery(query)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapCancel(sender: AnyObject) {
        resignResponders()
        dismissViewControllerAnimated(true, completion: nil)
    }
}
