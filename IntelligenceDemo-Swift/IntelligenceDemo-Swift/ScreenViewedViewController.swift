//
//  ScreenViewedViewController.swift
//  IntelligenceDemo-Swift
//
//  Created by Michael Lake on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit

import IntelligenceSDK

let IntelligenceDemoStoredDeviceTokenKey = "IntelligenceDemoStoredDeviceTokenKey"

class ScreenViewedViewController : UIViewController {
	
	@IBOutlet weak var clockLabel: UILabel!
	
	var startDate:NSDate? = nil
	var timer:Timer? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "Screen Viewed Event Timer"
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
        NotificationCenter.default.addObserver(self, selector: #selector(ScreenViewedViewController.restoreTimeAndStartClock), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)

		NotificationCenter.default.addObserver(self, selector: #selector(ScreenViewedViewController.stopClockAndStoreTime), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
		
		NotificationCenter.default.addObserver(self, selector: #selector(ScreenViewedViewController.sendAnalytics), name: NSNotification.Name.UIApplicationWillTerminate, object: nil)
		
		self.clearTimeAndStartClock()
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		self.stopClockAndStoreTime()
		self.sendAnalytics()
		
		NotificationCenter.default.removeObserver(self);
		
		super.viewDidDisappear(animated)
	}
	
	// MARK: - NSTimer
	
    @objc func timerFired(timer: Timer) {
		guard let startDate = self.startDate else {
			return
		}

		let previousSeconds = UserDefaults.standard.double(forKey: self.title!)
		self.clockLabel.text = self.clockTime(from: -startDate.timeIntervalSinceNow + previousSeconds)
	}
	
	// MARK: - Internal
	
    @objc internal func restoreTimeAndStartClock() {
		let previousSeconds = UserDefaults.standard.double(forKey:
            self.title!)
		self.clockLabel.text = self.clockTime(from: previousSeconds)
		
		self.startClock()
	}
	
	internal func clearTimeAndStartClock() {
		UserDefaults.standard.set(0.0, forKey: self.title!)
		UserDefaults.standard.synchronize()
		
		self.clockLabel.text = self.clockTime(from: 0.0)
		
		self.startClock()
	}
	
	internal func startClock() {
		self.startDate = NSDate()
		
		self.timer?.invalidate()
        self.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(ScreenViewedViewController.timerFired(timer:)), userInfo: nil, repeats: true)
	}
	
	internal func stopClock() {
		self.startDate = nil
		
		self.timer?.invalidate()
		self.timer = nil
	}
	
    @objc internal func stopClockAndStoreTime() {
		guard let startDate = self.startDate else {
			return
		}
		
		let previousSeconds = UserDefaults.standard.double(forKey:
            self.title!)
		let viewingDuration = -startDate.timeIntervalSinceNow + previousSeconds
		
		self.stopClock()
		
		UserDefaults.standard.set(viewingDuration, forKey: self.title!)
		UserDefaults.standard.synchronize()
	}
	
    internal func clockTime(from seconds: TimeInterval) -> String {
        var seconds = seconds
        let minutes = floor(seconds / 60.0)
		
		seconds -= minutes * 60
		
		return String(format: "%02.0lf:%02.0lf", minutes, seconds)
	}
	
    @objc internal func sendAnalytics() {
		let viewingDuration = UserDefaults.standard.double(forKey: self.title!)
		
        let event = ScreenViewedEvent(screenName: self.title!, viewingDuration: viewingDuration)
		IntelligenceManager.intelligence?.analytics.track(event: event)
	}
}
