//
//  IntelligenceLocationGeofenceQueryViewController.swift
//  IntelligenceDemo-Swift
//
//  Created by Josep Rodriguez on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit
import IntelligenceSDK

protocol GeofenceQueryBuilderDelegate {
    
    func didSelectGeofenceQuery(geofenceQuery:GeofenceQuery)
    
}

class IntelligenceLocationGeofenceQueryViewController: UIViewController {

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
        
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(IntelligenceLocationGeofenceQueryViewController.resignResponders)))
        
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
        
        if let text = latitudeText.text, text.characters.count > 0, let latitudeFromText = Double(text) {
            latitude = latitudeFromText
        }
        else {
            latitude = 0
        }
        
        
        let longitude : Double
        if let text = longitudeText.text, text.characters.count > 0, let longitudeFromText = Double(text) {
            longitude = longitudeFromText
        }
        else {
            longitude = 0
        }
        
        
        let radius : Double
        
        if let text = radiusText.text, text.characters.count > 0, let radiusFromText = Double(text) {
            radius = radiusFromText
        }
        else {
            radius = 40_075_000 // The circumference of the Earth
        }
        
        
        let query = GeofenceQuery(location: Coordinate(withLatitude: latitude, longitude: longitude),
            radius: radius)

        query.pageSize = (pageSizeText.text ?? "").characters.count > 0 ? Int(pageSizeText.text!) : nil
        query.pageNumber = (pageText.text ?? "").characters.count > 0 ? Int(pageText.text!) : nil
            
        delegate?.didSelectGeofenceQuery(geofenceQuery: query)
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapCancel(sender: AnyObject) {
        resignResponders()
        dismiss(animated: true, completion: nil)
    }
}
