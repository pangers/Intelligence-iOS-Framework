//
//  PHXPhoenixManager.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXPhoenixManager.h"

@interface PHXPhoenixManager ()

@property(nonatomic,readwrite,strong) Phoenix* phoenix;

@end

@implementation PHXPhoenixManager

+(instancetype) sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        // Attempt to instantiate Phoenix from file.
        NSError *err;
        self.phoenix = [[Phoenix alloc] initWithFile:@"PhoenixConfiguration" inBundle:[NSBundle mainBundle] error:&err];
        
        if (err != nil) {
            // Handle error, developer needs to resolve any errors thrown here, these should not be visible to the user
            // and generally indicate that something has gone wrong and needs to be resolved.
            NSLog(@"Error initialising Phoenix: %zd", err.code);
        }
        
        NSParameterAssert(err == nil && self.phoenix != nil);
        [self.phoenix setNetworkDelegate:self];
    });
}


-(void) startup
{
    [self.phoenix startup];
}


@end
