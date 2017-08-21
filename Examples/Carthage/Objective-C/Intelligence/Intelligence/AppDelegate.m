//
//  AppDelegate.m
//  Intelligence
//
//  Created by chethan.palaksha on 19/4/17.
//  Copyright © 2017 TigerSpike. All rights reserved.
//

#import "AppDelegate.h"
#import "INTIntelligenceManager.h"
#import "INTStartupViewController.h"

NSString * const IntelligenceDemoStoredDeviceTokenKey = @"IntelligenceDemoStoredDeviceTokenKey";

@interface AppDelegate () <INTDelegate>

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self startupIntelligence];
    
    return YES;
}

- (INTStartupViewController *)startupViewController {
    if ([self.window.rootViewController isKindOfClass:[INTStartupViewController class]]) {
        return self.window.rootViewController;
    }
    return nil;
}

-(void) startupIntelligence {
    [[self startupViewController] setState:INTStartupStateStarting];
    
    // Attempt to instantiate Intelligence from file.
    NSError *err;
    Intelligence* intelligence = [[Intelligence alloc] initWithDelegate:self file:@"IntelligenceConfiguration" inBundle:[NSBundle mainBundle] error:&err];
    
    if (err != nil) {
        // Handle error, developer needs to resolve any errors thrown here, these should not be visible to the user
        // and generally indicate that something has gone wrong and needs to be resolved.
        if ([ConfigurationErrorDomain rangeOfString: err.domain].location != NSNotFound) {
            
            switch (err.code) {
                    
                case ConfigurationErrorFileNotFoundError:
                    [self unrecoverableAlertWithMessage:@"The file you specified does not exist!"];
                    break;
                    
                case ConfigurationErrorInvalidFileError:
                    [self unrecoverableAlertWithMessage:@"The file is invalid! Check that the JSON provided is correct."];
                    break;
                    
                case ConfigurationErrorMissingPropertyError:
                    [self unrecoverableAlertWithMessage:@"You missed a property!"];
                    break;
                    
                case ConfigurationErrorInvalidPropertyError:
                    [self unrecoverableAlertWithMessage:@"There is an invalid property!"];
                    break;
                    
                default:
                    [self unrecoverableAlertWithMessage:@"Unknown initialization error!"];
                    break;
            }
        }
        else {
            [self unrecoverableAlertWithMessage:@"Unknown initialization error!"];
        }
    }
    
    // Start intelligence, will throw a network error if something is configured incorrectly.
    [intelligence startup:^(BOOL success) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            if (success) {
                // Setup intelligence
                [INTIntelligenceManager setupIntelligence:intelligence];
                
                // Track test event.
                INTEvent *myTestEvent = [[INTEvent alloc] initWithType:@"Intelligence.Test.Event.Type" value:1.0 targetId:@"5" metadata:nil];
                [intelligence.analytics track:myTestEvent];
                
                [[self startupViewController] setState:INTStartupStateStarted];
            }
            else {
                [self didFailToStartupIntelligence];
            }
        }];
    }];
}

-(void) didFailToStartupIntelligence {
    [[self startupViewController] setState:INTStartupStateFailed];
    
    NSString* message = @"Intelligence was unable to initialise properly. This can lead to unexpected behaviour. Please restart the app to retry the Intelligence startup.";
    UIAlertController* viewController = [UIAlertController alertControllerWithTitle:@"Error"
                                                                            message:message
                                                                     preferredStyle:UIAlertControllerStyleAlert];
    
    [viewController addAction:[UIAlertAction actionWithTitle:@"Retry"
                                                       style:UIAlertActionStyleCancel
                                                     handler:^(UIAlertAction * _Nonnull action) {
                                                         [self startupIntelligence];
                                                     }]];
    
    [self.window.rootViewController presentViewController:viewController
                                                 animated:YES
                                               completion:nil];
}

-(void) doSegueToDemo
{
    [self.window.rootViewController performSegueWithIdentifier:@"intelligenceStartedUp" sender:self];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Shutdown Intelligence in the applicationWillTerminate method so Intelligence has time
    // to teardown properly.
    [[INTIntelligenceManager intelligence] shutdown];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[[INTIntelligenceManager intelligence] analytics] pause];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[[INTIntelligenceManager intelligence] analytics] resume];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    __weak __typeof(self) weakSelf = self;
    [[[INTIntelligenceManager intelligence] identity] registerDeviceTokenWith:deviceToken callback:^(NSInteger tokenId, NSError * _Nullable error) {
        if (error != nil) {
            [weakSelf alertWithError:error];
        } else {
            // Store token id for unregistration. For this example I have stored it in user defaults.
            // However, this should be stored in the keychain as the app may be uninstalled and reinstalled
            // multiple times and may receive the same device token from Apple.
            [[NSUserDefaults standardUserDefaults] setInteger:tokenId forKey:IntelligenceDemoStoredDeviceTokenKey];
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

/// This method should only be called if there is an error returned by startup with the domain
/// 'ConfigurationErrorDomain' or if one of the INTIntelligenceDelegate methods is invoked after
/// calling startup.
/// This method will present an alert and put the app into an unrecoverable state.
/// You will need to run the app again in order to try startup again.
- (void)unrecoverableAlertWithMessage:(NSString*)message {
    // Notify startup view controller of new state.
    [[self startupViewController] setState:INTStartupStateFailed];
    // Present alert...
    [self alertWithMessage:message];
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
    
    if (presenterViewController.view.window == nil) {
        // presenterViewController in not yet atttached to the window
        __weak __typeof(self) weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [weakSelf alertWithMessage:message];
        });
        return;
    }
    
    UIAlertController* controller = [UIAlertController alertControllerWithTitle:@"Intelligence Demo" message:message preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
    [presenterViewController presentViewController:controller animated:YES completion:nil];
}

#pragma mark - INTIntelligenceDelegate

/// Credentials provided are incorrect. Will not distinguish between incorrect client or user credentials.
- (void)credentialsIncorrectForIntelligence:(Intelligence * __nonnull)intelligence {
    [self unrecoverableAlertWithMessage:@"Unrecoverable error occurred during login, check credentials for Intelligence accounts."];
}

/// Account has been disabled and no longer active. Credentials are no longer valid.
- (void)accountDisabledForIntelligence:(Intelligence * __nonnull)intelligence {
    [self unrecoverableAlertWithMessage:@"Unrecoverable error occurred during login, the Intelligence account is disabled."];
}

/// Account has failed to authentication multiple times and is now locked. Requires an administrator to unlock the account.
- (void)accountLockedForIntelligence:(Intelligence * __nonnull)intelligence {
    [self unrecoverableAlertWithMessage:@"Unrecoverable error occurred during login, the Intelligence account is locked. Contact an Intelligence Administrator."];
}

/// Token is invalid or expired, this may occur if your Application is configured incorrectly.
- (void)tokenInvalidOrExpiredForIntelligence:(Intelligence * __nonnull)intelligence {
    [self unrecoverableAlertWithMessage:@"Unrecoverable error occurred during user creation, check credentials for Intelligence accounts."];
}

/// Unable to create SDK user, this may occur if a user with the randomized credentials already exists (highly unlikely) or your Application is configured incorrectly and has the wrong permissions.
- (void)userCreationFailedForIntelligence:(Intelligence * __nonnull)intelligence {
    [self unrecoverableAlertWithMessage:@"Unrecoverable error occurred during user creation, check Intelligence accounts are configured correctly."];
}

/// User is required to login again, developer must implement this method you may present a 'Login Screen' or silently call identity.login with stored credentials.
- (void)userLoginRequiredForIntelligence:(Intelligence * __nonnull)intelligence {
    [self unrecoverableAlertWithMessage:@"Token expired, you will need to login again."];
}

/// Unable to assign provided sdk_user_role to your newly created user. This may occur if the Application is configured incorrectly in the backend and doesn't have the correct permissions or the role doesn't exist.
- (void)userRoleAssignmentFailedForIntelligence:(Intelligence * __nonnull)intelligence {
    [self unrecoverableAlertWithMessage:@"Unrecoverable error occurred during user role assignment, if this happens consistently please confirm that Intelligence accounts are configured correctly."];
}



@end
