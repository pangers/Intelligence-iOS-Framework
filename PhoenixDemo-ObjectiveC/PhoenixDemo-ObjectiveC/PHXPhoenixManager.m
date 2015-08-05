//
//  PHXPhoenixManager.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXPhoenixManager.h"

@interface PHXPhoenixManager () <PHXPhoenixNetworkDelegate>

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
        [instance.phoenix setNetworkDelegate:instance];
    });
    
    return instance;
}

-(void) startup
{
    // Instantiate Phoenix using PhoenixConfiguration.json file.
    [self.phoenix startupWithCallback:^(BOOL authenticated) {
        NSLog(@"Anonymous login %d", authenticated);
        if (authenticated) {
            NSString *username = @"chris.nevin@tigerspike.com";
            NSString *password = @"tigerspike123";
            [self.phoenix loginWithUsername:username password:password callback:^(BOOL authenticated) {
                NSLog(@"Logged in %d", authenticated);
            }];
        }
    }];
}


@end
