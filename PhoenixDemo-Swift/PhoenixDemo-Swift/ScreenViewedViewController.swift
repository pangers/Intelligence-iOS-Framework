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
		
		self.startDate = NSDate()
		self.timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("timerFired:"), userInfo: nil, repeats: true)
	}
	
	override func viewDidDisappear(animated: Bool) {
		guard let startDate = self.startDate else {
			return
		}
		
		PhoenixManager.phoenix?.analytics.trackScreenViewed(self.title!, viewingDuration: -startDate.timeIntervalSinceNow)
		
		super.viewDidDisappear(animated)
	}
	
	// MARK: - NSTimer
	
	func timerFired(timer: NSTimer) {
		guard let startDate = self.startDate else {
			return
		}
		
		var seconds = -startDate.timeIntervalSinceNow
		let minutes = floor(seconds / 60.0)
		
		seconds -= minutes * 60
		
		self.clockLabel.text = String(format: "%02.0lf:%02.0lf", minutes, seconds)
	}
}
