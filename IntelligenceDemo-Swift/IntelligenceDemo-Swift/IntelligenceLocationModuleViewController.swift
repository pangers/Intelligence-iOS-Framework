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

class IntelligenceLocationModuleViewController: UIViewController, UITableViewDataSource, MKMapViewDelegate, LocationModuleDelegate, GeofenceQueryBuilderDelegate {

    // MARK: - Constants
    private static let cellIdentifier = "cell"

    // MARK: - Properties
    private var eventsTitles = [String]()
    private lazy var locationManager = CLLocationManager()
    private var lastDownloadedGeofences: [Geofence]?
    private var timer: Timer?

    // MARK: - IBOutlets
    @IBOutlet var downloadButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var monitoringButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        IntelligenceManager.intelligence!.location.locationDelegate = self

        // Using the best kind of accuracy for demo purposes.
        IntelligenceManager.intelligence!.location.setLocationAccuracy(accuracy: kCLLocationAccuracyBest)
    }

    deinit {
        // On leaving stop monitoring.
        IntelligenceManager.intelligence?.location.stopMonitoringGeofences()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        timer = Timer.scheduledTimer(timeInterval: 10, target: self, selector: #selector(IntelligenceLocationModuleViewController.refreshGeofences), userInfo: nil, repeats: true)

        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedAlways && authorizationStatus != .authorizedWhenInUse {
            locationManager.requestAlwaysAuthorization()
        }

        mapView.setUserTrackingMode(.follow, animated: true)

        self.tableView.reloadData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
        timer = nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        if segue.identifier == "download" {
            let geofenceBuilderViewController = segue.destination as! IntelligenceLocationGeofenceQueryViewController
            geofenceBuilderViewController.latitude = locationManager.location?.coordinate.latitude
            geofenceBuilderViewController.longitude = locationManager.location?.coordinate.longitude
            geofenceBuilderViewController.delegate = self
        }
    }

    // MARK: - IBActions

    @IBAction func didTapMonitoringButton(sender: Any) {
        guard let locationModule = IntelligenceManager.intelligence?.location else {
            return
        }

        if locationModule.isMonitoringGeofences() {
            locationModule.stopMonitoringGeofences()
            addRecord(text: "Stopped monitoring")
            self.monitoringButton.setTitle("Enable monitoring", for: .normal)
        } else {
            if let lastDownloadedGeofences = lastDownloadedGeofences {
                locationModule.startMonitoringGeofences(geofences: lastDownloadedGeofences)
                display(geofences: lastDownloadedGeofences)
                addRecord(text: "Started monitoring")
                self.monitoringButton.setTitle("Disable monitoring", for: .normal)
            } else {
                addRecord(text: "No geofences available.")
            }
        }

        refreshGeofences()
    }

    // MARK: - GeofenceQueryBuilderDelegate and handling result of download

    func didSelectGeofenceQuery(geofenceQuery: GeofenceQuery) {
        IntelligenceManager.intelligence!.location.downloadGeofences(queryDetails: geofenceQuery) { [weak self] (geofences, error) -> Void in

            OperationQueue.main.addOperation({ () -> Void in
                self?.didReceiveGeofences(geofences: geofences, error: error)
            })
        }
    }

    func didReceiveGeofences(geofences: [Geofence]?, error: NSError?) {
        guard let geofences = geofences, error == nil else {
            if error != nil {
                addRecord(text: "Error occured while downloading geofences")
                addRecord(text: "\(String(describing: error))")
            } else {
                addRecord(text: "No geofences fetched")
            }
            return
        }

        lastDownloadedGeofences = geofences

        refreshGeofences()

        if IntelligenceManager.intelligence!.location.isMonitoringGeofences() {
            IntelligenceManager.intelligence!.location.startMonitoringGeofences(geofences: geofences)
        }

        addRecord(text: "Fetched \(geofences.count) geofences")
    }

    // MARK: - IntelligenceLocationDelegate

    func intelligenceLocation(location: LocationModuleProtocol, didEnterGeofence geofence: Geofence) {
        addRecord(text: "Entered \(geofence.name)")
    }

    func intelligenceLocation(location: LocationModuleProtocol, didExitGeofence geofence: Geofence) {
        addRecord(text: "Exited \(geofence.name)")
    }

    // MARK: - Table view data source

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventsTitles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCell(withIdentifier: IntelligenceLocationModuleViewController.cellIdentifier, for: indexPath)
        cell.textLabel?.text = eventsTitles[indexPath.row]
        return cell
    }

    // MARK: - MKMapViewDelegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let circleRenderer = MKCircleRenderer(circle: overlay as! MKCircle)

        var color: UIColor = .clear
        if let intelligenceLocation = IntelligenceManager.intelligence?.location {
            color = intelligenceLocation.isMonitoringGeofences() ? .green : .red
        }

        circleRenderer.fillColor = color.withAlphaComponent(0.4)
        circleRenderer.strokeColor = color
        circleRenderer.lineWidth = 2
        return circleRenderer
    }

    // MARK: - Helpers

    func addRecord(text: String) {
        self.eventsTitles.insert(text, at: 0)
        OperationQueue.main.addOperation { () -> Void in
            self.tableView.reloadData()
        }
    }

    @objc func refreshGeofences() {
        if let geofences = lastDownloadedGeofences {
            display(geofences: geofences)
        }
    }

    func display(geofences: [Geofence]) {
        mapView.removeOverlays(mapView.overlays)

        for geofence in geofences {

            // take a look at : https://tigerspike.atlassian.net/browse/INT-968
            // and https://tigerspike.atlassian.net/browse/INT-967
            let radius = geofence.radius >= 100 ? geofence.radius : 100

            let coordinate = CLLocationCoordinate2D(latitude: geofence.latitude, longitude: geofence.longitude)
            let circle = MKCircle(center: coordinate, radius: radius)
            mapView.add(circle)
        }
    }
}
