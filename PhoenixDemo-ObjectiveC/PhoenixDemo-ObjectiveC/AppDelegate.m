//
//  AppDelegate.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Rui Silvestre on 20/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "AppDelegate.h"
@import PhoenixSDK;

@interface AppDelegate () <PhoenixNetworkDelegate>

@property (nonatomic) Phoenix *phoenix;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
	// Override point for customization after application launch.
    
    // Instantiate Phoenix using PhoenixConfiguration.json file.
    
    // Attempt to instantiate Phoenix from file.
    NSError *err;
    self.phoenix = [[Phoenix alloc] initWithFile:@"PhoenixConfiguration" inBundle:[NSBundle mainBundle] error:&err];
    if (nil != err) {
        // Handle error, developer needs to resolve any errors thrown here, these should not be visible to the user
        // and generally indicate that something has gone wrong and needs to be resolved.
        NSLog(@"Error initialising Phoenix: %zd", err.code);
    }
    NSParameterAssert(err == nil && self.phoenix != nil);
    [self.phoenix setNetworkDelegate:self];
    [self.phoenix tryLogin:^(NSData * data, NSURLResponse * response, NSError * error) {
        NSLog(@"Error = %@", error.localizedDescription);
        NSLog(@"Response = %@", response);
        NSLog(@"Data = %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    }];
	return YES;
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

#pragma mark - Phoenix Networking Delegate

- (void)authenticationFailed:(nullable NSData *)data response:(nullable NSURLResponse *)response error:(nullable NSError *)error {
    NSLog(@"Cannot authenticate: %@", error.localizedDescription);
}

@end
