//
//  IntelligenceLocationModuleViewController.swift
//  IntelligenceDemo-Swift
//
//  Created by Josep Rodriguez on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit
import MapKit
import IntelligenceSDK

class IntelligenceLocationModuleViewController : UIViewController, UITableViewDataSource, MKMapViewDelegate, LocationModuleDelegate, GeofenceQueryBuilderDelegate {
    
    // MARK:- Constants
    private static let cellIdentifier = "cell"
    
    // MARK:- Properties
    private var eventsTitles = [String]()
    private lazy var locationManager = CLLocationManager()
    private var lastDownloadedGeofences:[Geofence]?
    private var timer:NSTimer?
    
    // MARK:- IBOutlets
    @IBOutlet var downloadButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var monitoringButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IntelligenceManager.intelligence!.location.locationDelegate = self
        
        // Using the best kind of accuracy for demo purposes.
        IntelligenceManager.intelligence!.location.setLocationAccuracy(kCLLocationAccuracyBest)
    }
    
    deinit {
        // On leaving stop monitoring.
        IntelligenceManager.intelligence?.location.stopMonitoringGeofences()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("refreshGeofences"), userInfo: nil, repeats: true)
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .AuthorizedAlways && authorizationStatus != .AuthorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }
        
        mapView.setUserTrackingMode(.Follow, animated: true)
        
        self.tableView.reloadData()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == "download" {
            let geofenceBuilderViewController = segue.destinationViewController as! IntelligenceLocationGeofenceQueryViewController
            geofenceBuilderViewController.latitude = locationManager.location?.coordinate.latitude
            geofenceBuilderViewController.longitude = locationManager.location?.coordinate.longitude
            geofenceBuilderViewController.delegate = self
        }
    }
    
    // MARK:- IBActions
    
    @IBAction func didTapMonitoringButton(sender: AnyObject) {
        let locationModule = IntelligenceManager.intelligence!.location
        
        if locationModule.isMonitoringGeofences() {
            locationModule.stopMonitoringGeofences()
            addRecord("Stopped monitoring")
            self.monitoringButton.setTitle("Enable monitoring", forState: .Normal)
        }
        else {
            if let lastDownloadedGeofences = lastDownloadedGeofences {
                locationModule.startMonitoringGeofences(lastDownloadedGeofences)
                displayGeofences(lastDownloadedGeofences)
                addRecord("Started monitoring")
                self.monitoringButton.setTitle("Disable monitoring", forState: .Normal)
            }
            else {
                addRecord("No geofences available.")
            }
        }
        
        refreshGeofences()
    }
    
    // MARK:- GeofenceQueryBuilderDelegate and handling result of download
    
    func didSelectGeofenceQuery(geofenceQuery: GeofenceQuery) {
        IntelligenceManager.intelligence!.location.downloadGeofences(geofenceQuery) { [weak self] (geofences, error) -> Void in
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self?.didReceiveGeofences(geofences,error:error)
            })
        }
    }
    
    func didReceiveGeofences(geofences: [Geofence]?, error:NSError?) {
        guard let geofences = geofences where error == nil else {
            if error != nil {
                addRecord("Error occured while downloading geofences")
                addRecord("\(error)")
            }
            else {
                addRecord("No geofences fetched")
            }
            return
        }
        
        lastDownloadedGeofences = geofences
        
        refreshGeofences()
        
        if IntelligenceManager.intelligence!.location.isMonitoringGeofences() {
            IntelligenceManager.intelligence!.location.startMonitoringGeofences(geofences)
        }
        
        addRecord("Fetched \(geofences.count) geofences")
    }
    
    // MARK:- IntelligenceLocationDelegate
    
    func intelligenceLocation(location: LocationModuleProtocol, didEnterGeofence geofence:Geofence) {
        addRecord("Entered \(geofence.name)")
    }
    
    func intelligenceLocation(location: LocationModuleProtocol, didExitGeofence geofence:Geofence) {
        addRecord("Exited \(geofence.name)")
    }
    
    // MARK:- Table view data source
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsTitles.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier(IntelligenceLocationModuleViewController.cellIdentifier, forIndexPath: indexPath)
        cell.textLabel?.text = eventsTitles[indexPath.row]
        return cell
    }
    
    // MARK:- MKMapViewDelegate
    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(circle: overlay as! MKCircle)
        let color = IntelligenceManager.intelligence!.location.isMonitoringGeofences() ? UIColor.greenColor() : UIColor.redColor()
        circleRenderer.fillColor = color.colorWithAlphaComponent(0.4)
        circleRenderer.strokeColor = color
        circleRenderer.lineWidth = 2
        return circleRenderer
    }

    // MARK:- Helpers
    
    func addRecord(text:String) {
        self.eventsTitles.insert(text, atIndex: 0)
        NSOperationQueue.mainQueue().addOperationWithBlock { () -> Void in
            self.tableView.reloadData()
        }
    }
    
    func refreshGeofences(){
        if let geofences = lastDownloadedGeofences {
            displayGeofences(geofences)
        }
    }
 
    func displayGeofences(geofences:[Geofence]){
        mapView.removeOverlays(mapView.overlays)
        
        for geofence in geofences {
            let coordinate = CLLocationCoordinate2D(latitude: geofence.latitude, longitude: geofence.longitude)
            let circle = MKCircle(centerCoordinate: coordinate, radius: geofence.radius)
            mapView.addOverlay(circle)
        }
    }
}