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
    @IBOutlet weak var sortByText: UITextField!
    @IBOutlet weak var sortDirectionSegmentedControl: UISegmentedControl!

    @IBOutlet var sortByPickerView: UIPickerView!
    @IBOutlet var accessoryView: UIView!

    // MARK:- Properties
    var latitude:Double?
    var longitude:Double?
    var delegate:GeofenceQueryBuilderDelegate?
    
    // MARK:- ViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sortByText.inputView = sortByPickerView

        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: Selector("resignResponders")))
        
        self.latitudeText.text = latitude != nil ? String(latitude!) : ""
        self.longitudeText.text = longitude != nil ? String(longitude!) : ""
        self.sortByText.text = "Distance"
        
        // Set accessory view to all texts:
        [latitudeText, longitudeText, pageSizeText, pageText, radiusText, sortByText].forEach {
            $0.inputAccessoryView = accessoryView
        }
    }
    
    func resignResponders() {
        [latitudeText, longitudeText, pageSizeText, pageText, radiusText, sortByText].forEach{
            $0.resignFirstResponder()
        }
    }
    
    // MARK:- IBActions
    
    @IBAction func didTapSave(sender: AnyObject) {
        resignResponders()
        
        let query = GeofenceQuery(location: PhoenixCoordinate(withLatitude: Double(latitudeText.text ?? "0") ?? 0, longitude: Double(longitudeText.text ?? "0") ?? 0))
        query.radius = Double(radiusText.text ?? "1000")
        query.pageSize = Int(pageSizeText.text ?? "10")
        query.pageNumber = Int(pageText.text ?? "1")
        query.sortingDirection = sortDirectionSegmentedControl.selectedSegmentIndex == 1 ? .Ascending : .Descending

        delegate?.didSelectGeofenceQuery(query)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func didTapCancel(sender: AnyObject) {
        resignResponders()
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK:- Sort by picker view datasourve
extension PhoenixLocationGeofenceQueryViewController : UIPickerViewDataSource {

    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 6
    }
}

extension PhoenixLocationGeofenceQueryViewController : UIPickerViewDelegate {
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch row {
        case GeofenceSortCriteria.Distance.rawValue:
            return "Distance"
            
        case GeofenceSortCriteria.Id.rawValue:
            return "Id"
            
        case GeofenceSortCriteria.Reference.rawValue:
            return "Reference"
            
        case GeofenceSortCriteria.Name.rawValue:
            return "Name"
            
        case GeofenceSortCriteria.Description.rawValue:
            return "Description"
            
        case GeofenceSortCriteria.Address.rawValue:
            return "Address"
            
        default:
            assert(false,"Should never have a row above the number of sort criteria")
        }
        
        return ""
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        sortByText.text = self.pickerView(pickerView, titleForRow: row, forComponent: component)
    }
}
