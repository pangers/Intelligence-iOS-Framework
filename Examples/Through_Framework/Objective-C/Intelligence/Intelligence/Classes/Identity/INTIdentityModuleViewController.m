//
//  INTIdentityModuleViewController.m
//  IntelligenceDemo-ObjectiveC
//
//  Created by Chris Nevin on 05/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "INTIdentityModuleViewController.h"
#import "AppDelegate.h"
#import "INTIntelligenceManager.h"
#import "INTManageUserViewController.h"
#import "INTViewUserViewController.h"

static NSString * const INTManageUserSegue = @"ManageUser";
static NSString * const INTViewUserSegue = @"ViewUser";

@interface INTIdentityModuleViewController()

@property (nonatomic, strong) INTUser *user;

@end


@implementation INTIdentityModuleViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:INTManageUserSegue]) {
        INTManageUserViewController *manageUser = segue.destinationViewController;
        manageUser.user = self.user;
    }
    else if ([segue.identifier isEqualToString:INTViewUserSegue]) {
        INTViewUserViewController *viewUser = segue.destinationViewController;
        viewUser.user = self.user;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self login];
    }
    else if (indexPath.row == 1) {
        [self getUser];
    }
    else {
        UIApplication *application = UIApplication.sharedApplication;
        AppDelegate *delegate = application.delegate;
        
        [delegate alertWithMessage:@"Unexpected Row"];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)login {
    __weak typeof(self) weakSelf = self;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enter Details" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Username";
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Password";
        textField.secureTextEntry = true;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *username = alert.textFields.firstObject.text;
        NSString *password = alert.textFields.lastObject.text;
        
        if (!(username.length != 0 && password.length != 0)) {
            return;
        }
        
        // logout before we login to clear the previous token (which means we check the login credentials, not just the token)
        [INTIntelligenceManager.intelligence.identity logout];
        
        [INTIntelligenceManager.intelligence.identity loginWith:username password:password callback:^(INTUser * _Nullable user, NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error != nil) {
                    UIApplication *application = UIApplication.sharedApplication;
                    AppDelegate *delegate = application.delegate;
                    
                    [delegate alertWithMessage:@"Login Failed"];
                }
                else {
                    self.user = user;
                    [strongSelf performSegueWithIdentifier:INTManageUserSegue sender:strongSelf];
                }
            });
        }];
    }]];
    
    [self presentViewController:alert animated:true completion:nil];
}

- (void)getUser {
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
                                                          
                                                          [INTIntelligenceManager.intelligence.identity getUserWith:[userId integerValue] callback:^(INTUser * _Nullable user, NSError * _Nullable error) {
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  __strong typeof(weakSelf) strongSelf = weakSelf;
                                                                  
                                                                  if (user != nil && strongSelf != nil) {
                                                                      strongSelf.user = user;
                                                                      
                                                                      [strongSelf performSegueWithIdentifier:INTViewUserSegue sender:strongSelf];
                                                                  }
                                                              });
                                                          }];
                                                      }]];
    
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)unwindOnLogout:(UIStoryboardSegue *)segue {
    
}

@end
