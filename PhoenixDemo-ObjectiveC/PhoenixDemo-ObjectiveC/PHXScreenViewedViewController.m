//
//  PHXScreenViewedViewController.m
//  IntelligenceDemo-ObjectiveC
//
//  Created by Michael Lake on 05/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXScreenViewedViewController.h"

#import "PHXIntelligenceManager.h"

@import IntelligenceSDK;

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
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(restoreTimeAndStartClock) name:UIApplicationDidBecomeActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopClockAndStoreTime) name:UIApplicationWillResignActiveNotification object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendAnalytics) name:UIApplicationWillTerminateNotification object:nil];
	 
	 [self clearTimeAndStartClock];
}

- (void)viewDidDisappear:(BOOL)animated {
	[self stopClockAndStoreTime];
	[self sendAnalytics];
	
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super viewDidDisappear:animated];
}

#pragma mark - NSTimer

- (void)timerFired:(NSTimer *)timer {
	NSTimeInterval previousSeconds = [[NSUserDefaults standardUserDefaults] doubleForKey:self.title];
	
	self.clockLabel.text = [self clockTimeFromSeconds:-self.startDate.timeIntervalSinceNow + previousSeconds];
}

#pragma mark - Internal

- (void)restoreTimeAndStartClock {
	NSTimeInterval previousSeconds = [[NSUserDefaults standardUserDefaults] doubleForKey:self.title];
	self.clockLabel.text = [self clockTimeFromSeconds:previousSeconds];
	
	[self startClock];
}

- (void)clearTimeAndStartClock {
	[[NSUserDefaults standardUserDefaults] setDouble:0.0 forKey:self.title];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	self.clockLabel.text = [self clockTimeFromSeconds:0.0];
	
	[self startClock];
}

- (void)startClock {
	self.startDate = [NSDate date];
	
	[self.timer invalidate];
	self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
}

- (void)stopClock {
	self.startDate = nil;
	
	[self.timer invalidate];
	self.timer = nil;
}

- (void)stopClockAndStoreTime {
	NSTimeInterval previousSeconds = [[NSUserDefaults standardUserDefaults] doubleForKey:self.title];
	NSTimeInterval viewingDuration = -self.startDate.timeIntervalSinceNow + previousSeconds;
	
	[self stopClock];
	
	[[NSUserDefaults standardUserDefaults] setDouble:viewingDuration forKey:self.title];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)clockTimeFromSeconds:(NSTimeInterval)seconds {
	double minutes = floor(seconds / 60.0);
	
	seconds -= minutes * 60;
	
	return [NSString stringWithFormat:@"%02.0lf:%02.0lf", minutes, seconds];
}

- (void)sendAnalytics {
	NSTimeInterval viewingDuration = [[NSUserDefaults standardUserDefaults] doubleForKey:self.title];
	
    PHXEvent *event = [[PHXScreenViewedEvent alloc] initWithScreenName:self.title viewingDuration:viewingDuration];
    
    [PHXIntelligenceManager.intelligence.analytics track:event];
}

@end
