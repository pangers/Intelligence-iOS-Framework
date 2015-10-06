//
//  ScreenViewedViewController.swift
//  PhoenixDemo-Swift
//
//  Created by Michael Lake on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

import UIKit

import PhoenixSDK

class ScreenViewedViewController : UIViewController {
	
	@IBOutlet weak var clockLabel: UILabel!
	
	var startDate:NSDate? = nil
	var timer:NSTimer? = nil
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.title = "Screen Viewed Event Timer"
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("restoreTimeAndStartClock"), name: UIApplicationDidBecomeActiveNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("stopClockAndStoreTime"), name: UIApplicationWillResignActiveNotification, object: nil)
		
		NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("sendAnalytics"), name: UIApplicationWillTerminateNotification, object: nil)
		
		self.clearTimeAndStartClock()
	}
	
	override func viewDidDisappear(animated: Bool) {
		self.stopClockAndStoreTime()
		self.sendAnalytics()
		
		NSNotificationCenter.defaultCenter().removeObserver(self);
		
		super.viewDidDisappear(animated)
	}
	
	// MARK: - NSTimer
	
	func timerFired(timer: NSTimer) {
		guard let startDate = self.startDate else {
			return
		}

		let previousSeconds = NSUserDefaults.standardUserDefaults().doubleForKey(self.title!)
		self.clockLabel.text = self.clockTime(fromSeconds: -startDate.timeIntervalSinceNow + previousSeconds)
	}
	
	// MARK: - Internal
	
	internal func restoreTimeAndStartClock() {
		let previousSeconds = NSUserDefaults.standardUserDefaults().doubleForKey(self.title!)
		self.clockLabel.text = self.clockTime(fromSeconds: previousSeconds)
		
		self.startClock()
	}
	
	internal func clearTimeAndStartClock() {
		NSUserDefaults.standardUserDefaults().setDouble(0.0, forKey: self.title!)
		NSUserDefaults.standardUserDefaults().synchronize()
		
		self.clockLabel.text = self.clockTime(fromSeconds: 0.0)
		
		self.startClock()
	}
	
	internal func startClock() {
		self.startDate = NSDate()
		
		self.timer?.invalidate()
		self.timer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: Selector("timerFired:"), userInfo: nil, repeats: true)
	}
	
	internal func stopClock() {
		self.startDate = nil
		
		self.timer?.invalidate()
		self.timer = nil
	}
	
	internal func stopClockAndStoreTime() {
		guard let startDate = self.startDate else {
			return
		}
		
		let previousSeconds = NSUserDefaults.standardUserDefaults().doubleForKey(self.title!)
		let viewingDuration = -startDate.timeIntervalSinceNow + previousSeconds
		
		self.stopClock()
		
		NSUserDefaults.standardUserDefaults().setDouble(viewingDuration, forKey: self.title!)
		NSUserDefaults.standardUserDefaults().synchronize()
	}
	
	internal func clockTime(var fromSeconds seconds: NSTimeInterval) -> String {
		let minutes = floor(seconds / 60.0)
		
		seconds -= minutes * 60
		
		return String(format: "%02.0lf:%02.0lf", minutes, seconds)
	}
	
	internal func sendAnalytics() {
		let viewingDuration = NSUserDefaults.standardUserDefaults().doubleForKey(self.title!)
		
		PhoenixManager.phoenix?.analytics.trackScreenViewed(self.title!, viewingDuration: viewingDuration)
	}
}
