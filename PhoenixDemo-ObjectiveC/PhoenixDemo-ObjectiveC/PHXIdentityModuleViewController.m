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
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        [application registerForRemoteNotifications];
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil]];
    } else if (indexPath.row == 2) {
        // Check if user defaults value is invalid (zero).
        if (tokenId == 0) {
            [delegate alertWithMessage:@"Not Registered!"];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            return;
        }
        [[[PHXPhoenixManager phoenix] identity] unregisterDeviceTokenWithId:tokenId callback:^(NSError * _Nullable error) {
            if (error != nil) {
                [delegate alertWithError: error];
            } else {
                [delegate alertWithMessage: @"Unregister Succeeded!"];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey: PhoenixDemoStoredDeviceTokenKey];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
