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
#import "PHXViewUserViewController.h"

static NSString * const PHXGetAndViewUser = @"GetAndViewUser";

@interface PHXIdentityModuleViewController()

@property (nonatomic, strong) PHXUser *user;

@end


@implementation PHXIdentityModuleViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:PHXGetAndViewUser]) {
        PHXViewUserViewController *viewUser = segue.destinationViewController;
        viewUser.user = self.user;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Enter Details"
                                                                                 message:nil
                                                                          preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"UserId";
        }];
        
        [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                            style:UIAlertActionStyleCancel
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                          }]];
        
        __weak typeof(self) weakSelf = self;
        [alertController addAction:[UIAlertAction actionWithTitle:@"Get User"
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction * _Nonnull action) {
                                                              
                                                              NSString *userId = alertController.textFields.firstObject.text;
                                                              
                                                              [PHXPhoenixManager.phoenix.identity getUser:[userId integerValue] callback:^(PHXUser * _Nullable user, NSError * _Nullable error) {
                                                                  dispatch_async(dispatch_get_main_queue(), ^{
                                                                      __strong typeof(weakSelf) strongSelf = weakSelf;
                                                                      
                                                                      if (user != nil && strongSelf != nil) {
                                                                          strongSelf.user = user;
                                                                          
                                                                          [strongSelf performSegueWithIdentifier:PHXGetAndViewUser sender:strongSelf];
                                                                      }
                                                                  });
                                                              }];
                                                          }]];
        
        [self presentViewController:alertController animated:true completion:nil];
        
        return;
    }
    
    UIApplication *application = UIApplication.sharedApplication;
    __weak AppDelegate *delegate = application.delegate;
    NSInteger tokenId = [[NSUserDefaults standardUserDefaults] integerForKey:PhoenixDemoStoredDeviceTokenKey];
    if (indexPath.row == 2) {
        // Check if user defaults value is valid (non-zero).
        if (tokenId != 0) {
            [delegate alertWithMessage:@"Already Registered!"];
        } else {
            [application registerForRemoteNotifications];
            [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil]];
        }
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    } else if (indexPath.row == 3) {
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
