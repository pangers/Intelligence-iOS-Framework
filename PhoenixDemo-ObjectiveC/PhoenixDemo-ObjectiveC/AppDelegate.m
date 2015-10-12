//
//  AppDelegate.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Rui Silvestre on 20/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "AppDelegate.h"
#import "PHXPhoenixManager.h"

@interface AppDelegate () <PHXDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Attempt to instantiate Phoenix from file.
    NSError *err;
    Phoenix* phoenix = [[Phoenix alloc] initWithDelegate:self file:@"PhoenixConfiguration" inBundle:[NSBundle mainBundle] error:&err];
    
    if (err != nil) {
        // Handle error, developer needs to resolve any errors thrown here, these should not be visible to the user
        // and generally indicate that something has gone wrong and needs to be resolved.
        NSLog(@"Error initialising Phoenix: %@", @(err.code));
    }
    
    NSParameterAssert(err == nil && phoenix != nil);
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    // Start phoenix, will throw a network error if something is configured incorrectly.
    [phoenix startup:^(BOOL success) {
        NSAssert(success, @"An error occured while initializing Phoenix.");

        // Track test event.
        PHXEvent *myTestEvent = [[PHXEvent alloc] initWithType:@"Phoenix.Test.Event.Type" value:1.0 targetId:@"5" metadata:nil];
        [phoenix.analytics track:myTestEvent];

        // Setup phoenix
        [PHXPhoenixManager setupPhoenix:phoenix];
        dispatch_semaphore_signal(semaphore);
    }];
    
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    return YES;
}

-(void) alertWithMessage:(NSString*)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* controller = [UIAlertController alertControllerWithTitle:@"Error" message:message preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self.window.rootViewController presentViewController:controller animated:YES completion:nil];
    });
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Shutdown Phoenix in the applicationWillTerminate method so Phoenix has time
    // to teardown properly.
    [[PHXPhoenixManager phoenix] shutdown];
}

#pragma mark - PHXPhoenixDelegate

/// Unable to create SDK user, this may occur if a user with the randomized credentials already exists (highly unlikely) or your Application is configured incorrectly and has the wrong permissions.
- (void)userCreationFailedForPhoenix:(Phoenix * __nonnull)phoenix {
    [self alertWithMessage:@"Unrecoverable error occurred during user creation, check Phoenix Intelligence accounts are configured correctly."];
}

/// User is required to login again, developer must implement this method you may present a 'Login Screen' or silently call identity.login with stored credentials.
- (void)userLoginRequiredForPhoenix:(Phoenix * __nonnull)phoenix {
    [self alertWithMessage:@"Present login screen or call identity.login with credentials stored in Keychain."];
}

/// Unable to assign provided sdk_user_role to your newly created user. This may occur if the Application is configured incorrectly in the backend and doesn't have the correct permissions or the role doesn't exist.
- (void)userRoleAssignmentFailedForPhoenix:(Phoenix * __nonnull)phoenix {
    [self alertWithMessage:@"Unrecoverable error occurred during user role assignment, if this happens consistently please confirm that Phoenix Intelligence accounts are configured correctly."];
}



@end
