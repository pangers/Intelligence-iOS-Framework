//
//  PHXPhoenixLocationManager.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Chris Nevin on 20/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXPhoenixLocationManager.h"
@import CoreLocation;

@interface PHXPhoenixLocationManager () <CLLocationManagerDelegate>

@property (nonatomic) CLLocationManager* locationManager;

@end


@implementation PHXPhoenixLocationManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    // Handle authorization changes in app if necessary...
}

- (void)requestAuthorization
{
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
        [self.locationManager requestAlwaysAuthorization];
    }
}

@end
