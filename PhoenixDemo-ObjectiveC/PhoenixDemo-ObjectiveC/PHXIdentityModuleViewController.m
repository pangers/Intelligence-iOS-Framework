//
//  PHXIdentityModuleViewController.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Chris Nevin on 05/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXIdentityModuleViewController.h"
#import "AppDelegate.h"
#import "PHXPhoenixManager.h"

@implementation PHXIdentityModuleViewController

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIApplication *application = UIApplication.sharedApplication;
    __weak AppDelegate *delegate = application.delegate;
    NSInteger tokenId = [[NSUserDefaults standardUserDefaults] integerForKey:PhoenixDemoStoredDeviceTokenKey];
    if (indexPath.row == 1) {
        // Check if user defaults value is valid (non-zero).
        if (tokenId != 0) {
            [delegate alertWithMessage:@"Already Registered!"];
        } else {
            [application registerForRemoteNotifications];
            [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil]];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (indexPath.row == 2) {
        // Check if user defaults value is invalid (zero).
        if (tokenId == 0) {
            [delegate alertWithMessage:@"Not Registered!"];
        }
        else {
            [[[PHXPhoenixManager phoenix] identity] unregisterDeviceTokenWithId:tokenId callback:^(NSError * _Nullable error) {
                BOOL notRegisteredError = [IdentityErrorDomain rangeOfString:error.domain].location != NSNotFound && error.code == IdentityErrorDeviceTokenNotRegisteredError;
                if (error != nil && !notRegisteredError) {
                    [delegate alertWithError: error];
                } else {
                    [[NSUserDefaults standardUserDefaults] removeObjectForKey: PhoenixDemoStoredDeviceTokenKey];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [delegate alertWithMessage: @"Unregister Succeeded!"];
                }
            }];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

@end
