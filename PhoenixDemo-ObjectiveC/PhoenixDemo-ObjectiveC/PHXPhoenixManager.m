//
//  PHXPhoenixManager.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXPhoenixManager.h"
#import "PHXPhoenixLocationManager.h"

@interface PHXPhoenixManager() <PHXPhoenixDelegate>

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
        instance.phoenix = [[Phoenix alloc] initWithDelegate:instance file:@"PhoenixConfiguration" inBundle:[NSBundle mainBundle] error:&err];
        
        if (err != nil) {
            // Handle error, developer needs to resolve any errors thrown here, these should not be visible to the user
            // and generally indicate that something has gone wrong and needs to be resolved.
            NSLog(@"Error initialising Phoenix: %zd", err.code);
        }
        
        NSParameterAssert(err == nil && instance.phoenix != nil);
        
        instance.locationManager = [[PHXPhoenixLocationManager alloc] init];
        
        // Start phoenix, will throw a network error if something is configured incorrectly.
        
        [instance.phoenix startup:^(BOOL success) {
            if (!success) {
                NSAssert(false, @"Could not instantiate Phoenix");
            }
        }];
        
        // Ask user to enable location services.
        [instance.locationManager requestAuthorization];
        
        // Track test event.
        PHXEvent *myTestEvent = [[PHXEvent alloc] initWithType:@"Phoenix.Test.Event.Type" value:1.0 targetId:5 metadata:nil];
        [instance.phoenix.analytics track:myTestEvent];
    });
    
    return instance;
}

+ (Phoenix*)phoenix {
    return [[self sharedInstance] phoenix];
}

- (void)alertWithMessage:(NSString*)message {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil];
    [controller addAction:action];
    [[[[[UIApplication sharedApplication] windows] firstObject] rootViewController] presentViewController:controller animated:true completion:nil];
}

- (void)userCreationFailedForPhoenix:(Phoenix *)phoenix {
    // Existing username, cannot create.
    [self alertWithMessage:@"Unrecoverable error occurred during user creation, check Phoenix Intelligence accounts are configured correctly."];
}

- (void)userLoginRequiredForPhoenix:(Phoenix *)phoenix {
    // Present login screen or call identity.login with credentials stored in Keychain.
    [self alertWithMessage:@"Token expired, you will need to login again."];
}

- (void)userRoleAssignmentFailedForPhoenix:(Phoenix *)phoenix {
    // Potentially invalid role specified.
    [self alertWithMessage:@"Unrecoverable error occurred during user role assignment, if this happens consistently please confirm that Phoenix Intelligence accounts are configured correctly."];
}

@end
