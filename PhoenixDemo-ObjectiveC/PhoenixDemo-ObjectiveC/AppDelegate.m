//
//  AppDelegate.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Rui Silvestre on 20/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "AppDelegate.h"
#import "PHXPhoenixManager.h"

@interface AppDelegate () <PHXPhoenixDelegate>

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
    
    // Start phoenix, will throw a network error if something is configured incorrectly.
    [phoenix startup:^(BOOL success) {
        NSAssert(success, @"An error occured while initializing Phoenix.");
        
        // Setup phoenix
        [PHXPhoenixManager setupPhoenix:phoenix];
        
        // Track test event.
        PHXEvent *myTestEvent = [[PHXEvent alloc] initWithType:@"Phoenix.Test.Event.Type" value:1.0 targetId:5 metadata:nil];
        [phoenix.analytics track:myTestEvent];
    }];
    
	return YES;
}

/// Unable to create SDK user, this may occur if a user with the randomized credentials already exists (highly unlikely) or your Application is configured incorrectly and has the wrong permissions.
- (void)userCreationFailedForPhoenix:(Phoenix * __nonnull)phoenix {
    
}

/// User is required to login again, developer must implement this method you may present a 'Login Screen' or silently call identity.login with stored credentials.
- (void)userLoginRequiredForPhoenix:(Phoenix * __nonnull)phoenix {
    
}

/// Unable to assign provided sdk_user_role to your newly created user. This may occur if the Application is configured incorrectly in the backend and doesn't have the correct permissions or the role doesn't exist.
- (void)userRoleAssignmentFailedForPhoenix:(Phoenix * __nonnull)phoenix {
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
	// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
	// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
	// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
	// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
	// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
	// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
	// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
