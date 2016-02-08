//
//  AppDelegate.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Rui Silvestre on 20/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "AppDelegate.h"
#import "PHXPhoenixManager.h"

NSString * const PhoenixDemoStoredDeviceTokenKey = @"PhoenixDemoStoredDeviceTokenKey";

@interface AppDelegate () <PHXDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self startupPhoenix];
    
    return YES;
}

-(void) startupPhoenix {
    // Attempt to instantiate Phoenix from file.
    NSError *err;
    Phoenix* phoenix = [[Phoenix alloc] initWithDelegate:self file:@"PhoenixConfiguration" inBundle:[NSBundle mainBundle] error:&err];
    
    if (err != nil) {
        // Handle error, developer needs to resolve any errors thrown here, these should not be visible to the user
        // and generally indicate that something has gone wrong and needs to be resolved.
        if ([ConfigurationErrorDomain rangeOfString: err.domain].location != NSNotFound) {
            
            switch (err.code) {
                    
                case ConfigurationErrorFileNotFoundError:
                    // The file you specified does not exist!
                    break;
                    
                case ConfigurationErrorInvalidFileError:
                    // The file is invalid! Check that the JSON provided is correct.
                    break;
                    
                case ConfigurationErrorMissingPropertyError:
                    // You missed a property!
                    break;
                    
                case ConfigurationErrorInvalidPropertyError:
                    // There is an invalid property!
                    break;
                    
                default:
                    // Unknown initialization error!
                    break;
            }
        }
        else {
            // Unknown initialization error!
        }

        // If you get an error here, you should check your configuration file and
        // how you initialize phoenix.
        assert(false);
    }
    
    // Start phoenix, will throw a network error if something is configured incorrectly.
    [phoenix startup:^(BOOL success) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        
            if (success) {
                // Setup phoenix
                [PHXPhoenixManager setupPhoenix:phoenix];

                // Track test event.
                PHXEvent *myTestEvent = [[PHXEvent alloc] initWithType:@"Phoenix.Test.Event.Type" value:1.0 targetId:@"5" metadata:nil];
                [phoenix.analytics track:myTestEvent];

                [self doSegueToDemo];
            }
            else {
                [self didFailToStartupPhoenix];
            }
        }];
    }];
}

-(void) didFailToStartupPhoenix {
    NSString* message = @"Phoenix was unable to initialise properly. This can lead to unexpected behaviour. Please restart the app to retry the Phoenix startup.";
    UIAlertController* viewController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                            message:message
                                                                     preferredStyle:UIAlertControllerStyleAlert];
    
    [viewController addAction:[UIAlertAction actionWithTitle:@"Retry"
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [self startupPhoenix];
    }]];
    
    [self.window.rootViewController presentViewController:viewController
                                                 animated:YES
                                               completion:nil];
}

-(void) doSegueToDemo
{
    [self.window.rootViewController performSegueWithIdentifier:@"phoenixStartedUp" sender:self];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Shutdown Phoenix in the applicationWillTerminate method so Phoenix has time
    // to teardown properly.
    [[PHXPhoenixManager phoenix] shutdown];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[[PHXPhoenixManager phoenix] analytics] pause];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[[PHXPhoenixManager phoenix] analytics] resume];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    __weak __typeof(self) weakSelf = self;
    [[[PHXPhoenixManager phoenix] identity] registerDeviceToken:deviceToken callback:^(NSInteger tokenId, NSError * _Nullable error) {
        if (error != nil) {
            [weakSelf alertWithError:error];
        } else {
            // Store token id for unregistration. For this example I have stored it in user defaults.
            // However, this should be stored in the keychain as the app may be uninstalled and reinstalled
            // multiple times and may receive the same device token from Apple.
            [[NSUserDefaults standardUserDefaults] setInteger:tokenId forKey:PhoenixDemoStoredDeviceTokenKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [weakSelf alertWithMessage:@"Registration Succeeded!"];
        }
    }];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [self alertWithMessage:@"Unable to Register for Push Notifications"];
}

#pragma mark - Alert

- (void)alertWithError:(NSError *)error {
    if ([error.domain isEqualToString:@"IdentityError"]) {
        [self alertWithMessage:[NSString stringWithFormat:@"Identity Error: %ld", (long)error.code]];
    } else if ([error.domain isEqualToString:@"RequestError"]) {
        [self alertWithMessage:[NSString stringWithFormat:@"Request Error: %ld", (long)error.code]];
    }
}

- (void)alertWithMessage:(NSString*)message {
    if (![NSThread isMainThread]) {
        [self performSelectorOnMainThread:@selector(alertWithMessage:) withObject:message waitUntilDone:YES];
        return;
    }
    
    UIViewController *presenterViewController = self.window.rootViewController;
    
    while (presenterViewController.presentedViewController != nil) {
        presenterViewController = presenterViewController.presentedViewController;
    }
    
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:@"Phoenix Demo" message:message preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [presenterViewController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - PHXPhoenixDelegate

/// Credentials provided are incorrect. Will not distinguish between incorrect client or user credentials.
- (void)credentialsIncorrectForPhoenix:(Phoenix * __nonnull)phoenix {
    [self alertWithMessage:@"Unrecoverable error occurred during login, check credentials for Phoenix Intelligence accounts."];
}

/// Account has been disabled and no longer active. Credentials are no longer valid.
- (void)accountDisabledForPhoenix:(Phoenix * __nonnull)phoenix {
    [self alertWithMessage:@"Unrecoverable error occurred during login, the Phoenix Intelligence account is disabled."];
}

/// Account has failed to authentication multiple times and is now locked. Requires an administrator to unlock the account.
- (void)accountLockedForPhoenix:(Phoenix * __nonnull)phoenix {
    [self alertWithMessage:@"Unrecoverable error occurred during login, the Phoenix Intelligence account is locked. Contact a Phoenix Intelligence Administrator."];
}

/// Token is invalid or expired, this may occur if your Application is configured incorrectly.
- (void)tokenInvalidOrExpiredForPhoenix:(Phoenix * __nonnull)phoenix {
    [self alertWithMessage:@"Unrecoverable error occurred during user creation, check credentials for Phoenix Intelligence accounts."];
}

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
