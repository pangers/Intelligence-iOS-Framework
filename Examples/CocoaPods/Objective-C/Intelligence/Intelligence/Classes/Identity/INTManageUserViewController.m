//
//  INTManageUserViewController.m
//  IntelligenceDemo-ObjectiveC
//
//  Created by Michael Lake on 09/02/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

#import "INTManageUserViewController.h"
#import "AppDelegate.h"
#import "INTViewUserViewController.h"

static NSString * const INTUpdateUserSegue = @"UpdateUser";
static NSString * const INTUnwindOnLogoutSegue = @"UnwindOnLogout";

@interface INTManageUserViewController ()

@end

@implementation INTManageUserViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:INTUpdateUserSegue]) {
        INTViewUserViewController *viewUser = segue.destinationViewController;
        viewUser.user = self.user;
    }
    else if ([segue.identifier isEqualToString:INTUnwindOnLogoutSegue]) {
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIApplication *application = UIApplication.sharedApplication;
    AppDelegate *delegate = application.delegate;
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self registerDeviceToken];
        }
        else if (indexPath.row == 1) {
            [self unregisterDeviceToken];
        }
        else {
            [delegate alertWithMessage:@"Unexpected Row"];
        }
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [self assignRole];
        }
        else if (indexPath.row == 1) {
            [self revokeRole];
        }
        else {
            [delegate alertWithMessage:@"Unexpected Row"];
        }
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            // Segue in IB will handle this
        }
        else {
            [delegate alertWithMessage:@"Unexpected Row"];
        }
    }
    else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            [self logout];
        }
        else {
            [delegate alertWithMessage:@"Unexpected Row"];
        }
    }
    else {
        [delegate alertWithMessage:@"Unexpected Section"];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)registerDeviceToken {
    UIApplication *application = UIApplication.sharedApplication;
    
    NSInteger tokenId = [[NSUserDefaults standardUserDefaults] integerForKey:IntelligenceDemoStoredDeviceTokenKey];
    
    if (tokenId != 0) {
        AppDelegate *delegate = application.delegate;
        [delegate alertWithMessage:@"Already Registered!"];
    } else {
        [application registerForRemoteNotifications];
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil]];
    }
}

- (void)unregisterDeviceToken {
    UIApplication *application = UIApplication.sharedApplication;
    AppDelegate *delegate = application.delegate;
    
    NSInteger tokenId = [[NSUserDefaults standardUserDefaults] integerForKey:IntelligenceDemoStoredDeviceTokenKey];
    
    if (tokenId == 0) {
        [delegate alertWithMessage:@"Not Registered!"];
        return;
    }
    
    [[[INTIntelligenceManager intelligence] identity] unregisterDeviceTokenWith:tokenId callback:^(NSError * _Nullable error) {
        BOOL notRegisteredError = [IdentityErrorDomain rangeOfString:error.domain].location != NSNotFound && error.code == IdentityErrorDeviceTokenNotRegisteredError;
        
        if (error != nil && !notRegisteredError) {
            [delegate alertWithError: error];
        } else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey: IntelligenceDemoStoredDeviceTokenKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [delegate alertWithMessage: @"Unregister Succeeded!"];
        }
    }];
}

- (void)assignRole {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Enter Details"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"RoleId";
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                      }]];
    
    __weak typeof(self) weakSelf = self;
    [alertController addAction:[UIAlertAction actionWithTitle:@"Assign Role"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          
                                                          NSString *roleId = alertController.textFields.firstObject.text;
                                                          
//                                                          [INTIntelligenceManager.intelligence.identity assignRoleTo:[roleId integerValue] user:weakSelf.user callback:^(INTUser * _Nullable user, NSError * _Nullable error) {
//                                                              dispatch_async(dispatch_get_main_queue(), ^{
//                                                                  UIApplication *application = UIApplication.sharedApplication;
//                                                                  AppDelegate *delegate = application.delegate;
//                                                                  
//                                                                  if (error != nil) {
//                                                                      [delegate alertWithMessage:[NSString stringWithFormat:@"Failed with error: %@", @(error.code)]];
//                                                                  }
//                                                                  else {
//                                                                      [delegate alertWithMessage:@"Role Assigned!"];
//                                                                  }
//                                                              });
//                                                          }];
                                                      }]];
    
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)revokeRole {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Enter Details"
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"RoleId";
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"Cancel"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                      }]];
    
    __weak typeof(self) weakSelf = self;
    [alertController addAction:[UIAlertAction actionWithTitle:@"Revoke Role"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction * _Nonnull action) {
                                                          
                                                          NSString *roleId = alertController.textFields.firstObject.text;
                                                          
//                                                          [INTIntelligenceManager.intelligence.identity revokeRoleWith:[roleId integerValue] user:weakSelf.user callback:^(INTUser * _Nullable user, NSError * _Nullable error) {
//                                                              dispatch_async(dispatch_get_main_queue(), ^{
//                                                                  UIApplication *application = UIApplication.sharedApplication;
//                                                                  AppDelegate *delegate = application.delegate;
//                                                                  
//                                                                  if (error != nil) {
//                                                                      [delegate alertWithMessage:[NSString stringWithFormat:@"Failed with error: %@", @(error.code)]];
//                                                                  }
//                                                                  else {
//                                                                      [delegate alertWithMessage:@"Role Revoked!"];
//                                                                  }
//                                                              });
//                                                          }];
                                                      }]];
    
    [self presentViewController:alertController animated:true completion:nil];
}

- (void)logout {
    [INTIntelligenceManager.intelligence.identity logout];
    
    self.user = nil;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: IntelligenceDemoStoredDeviceTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self performSegueWithIdentifier:INTUnwindOnLogoutSegue sender:self];
}

@end
