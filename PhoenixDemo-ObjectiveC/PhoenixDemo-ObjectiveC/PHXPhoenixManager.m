//
//  PHXPhoenixManager.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXPhoenixManager.h"
#import "PHXPhoenixLocationManager.h"

@interface PHXPhoenixManager()

@property (nonatomic) Phoenix* phoenix;
@property (nonatomic) PHXPhoenixLocationManager *locationManager;

@end

@implementation PHXPhoenixManager

+ (instancetype)sharedInstance {
    static PHXPhoenixManager* instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // Attempt to instantiate Phoenix from file.
        NSError *err;
        instance = [[PHXPhoenixManager alloc] init];
        instance.phoenix = [[Phoenix alloc] initWithFile:@"PhoenixConfiguration" inBundle:[NSBundle mainBundle] error:&err];
        
        if (err != nil) {
            // Handle error, developer needs to resolve any errors thrown here, these should not be visible to the user
            // and generally indicate that something has gone wrong and needs to be resolved.
            NSLog(@"Error initialising Phoenix: %zd", err.code);
        }
        
        NSParameterAssert(err == nil && instance.phoenix != nil);
        
        instance.locationManager = [[PHXPhoenixLocationManager alloc] init];
        
        // Start phoenix, will throw a network error if something is configured incorrectly.
        [instance.phoenix startup:^(NSError * _Nonnull error) {
            NSLog(@"Fundamental error occurred: %@", error);
        }];
        
        // Ask user to enable location services.
        [instance.locationManager requestAuthorization];
        
        // Track test event.
        PHXEvent *myTestEvent = [[PHXEvent alloc] initWithType:@"Phoenix.Test.Event.Type" value:1.0 targetId:@"5" metadata:nil];
        [instance.phoenix.analytics track:myTestEvent];
    });
    
    return instance;
}

+ (Phoenix*)phoenix {
    return [[self sharedInstance] phoenix];
}

@end
