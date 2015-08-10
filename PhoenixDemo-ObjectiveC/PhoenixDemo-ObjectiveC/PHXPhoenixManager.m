//
//  PHXPhoenixManager.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXPhoenixManager.h"

@interface PHXPhoenixManager()

@property(nonatomic,readwrite,strong) Phoenix* phoenix;

@end

@implementation PHXPhoenixManager

+(instancetype) sharedManager {
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
    });
    
    return instance;
}

-(void) startup
{
    // Start phoenix, will throw a network error if something is configured incorrectly.
    [self.phoenix startup:^(NSError * _Nonnull error) {
        NSLog(@"Fundamental error occurred: %@", error);
    }];
}


@end
