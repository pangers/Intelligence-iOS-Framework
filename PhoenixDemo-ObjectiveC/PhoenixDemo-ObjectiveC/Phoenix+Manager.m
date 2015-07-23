//
//  Phoenix+Manager.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Chris Nevin on 23/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "Phoenix+Manager.h"

@implementation Phoenix (Manager)

+ (Phoenix *)sharedInstance {
    static Phoenix *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Attempt to instantiate configuration from file.
        NSError *err;
        Configuration *configuration = [[Configuration alloc] initFromFile:@"PhoenixConfiguration"
                                                                  inBundle:[NSBundle mainBundle]
                                                                     error:&err];
        if (nil != err) {
            // Handle error, developer needs to resolve any errors thrown here, these should not be visible to the user
            // and generally indicate that something has gone wrong and needs to be resolved.
            NSLog(@"Error configuring Phoenix: %zd", err.code);
        }
        NSParameterAssert(err == nil && configuration != nil);
        // Create instance using Configuration object above.
        instance = [[Phoenix alloc] initWithConfiguration:configuration error:&err];
        if (nil != err) {
            // Handle error, developer needs to resolve any errors thrown here, these should not be visible to the user
            // and generally indicate that something has gone wrong and needs to be resolved.
            NSLog(@"Error initialising Phoenix: %zd", err.code);
        }
        NSParameterAssert(err == nil && instance != nil);
    });
    return instance;
}

@end
