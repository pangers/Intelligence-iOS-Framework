//
//  PHXScreenViewedViewController.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Michael Lake on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXScreenViewedViewController.h"

#import "PHXPhoenixManager.h"

@import PhoenixSDK;

@interface PHXScreenViewedViewController ()

@property (nonatomic, weak) IBOutlet UILabel *clockLabel;

@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation PHXScreenViewedViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Screen Viewed Event Timer";
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	self.startDate = [NSDate date];
	self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
	[PHXPhoenixManager.phoenix.analytics trackScreenViewed:self.title viewingDuration:-self.startDate.timeIntervalSinceNow];
	
	[super viewDidDisappear:animated];
}

#pragma mark - NSTimer

- (void)timerFired:(NSTimer *)timer {
	NSTimeInterval seconds = -self.startDate.timeIntervalSinceNow;
	double minutes = floor(seconds / 60.0);
	
	seconds -= minutes * 60;
	
	self.clockLabel.text = [NSString stringWithFormat:@"%02.0lf:%02.0lf", minutes, seconds];
}

@end
