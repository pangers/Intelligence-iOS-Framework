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
    if (indexPath.row == 1) {
        
        [application registerForRemoteNotifications];
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil]];
        
    } else if (indexPath.row == 2) {
        
        NSInteger tokenId = [[NSUserDefaults standardUserDefaults] integerForKey:PhoenixDemoStoredDeviceTokenKey];
        if (tokenId < 1) {
            [delegate alertWithMessage:@"Not Registered!"];
            return;
        }
        
        [[[PHXPhoenixManager phoenix] identity] unregisterDeviceTokenWithId:tokenId callback:^(NSError * _Nullable error) {
            if (error != nil) {
                [delegate alertWithError: error];
            } else {
                [delegate alertWithMessage: @"Unregister Succeeded!"];
            }
        }];
        
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
