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
#import "PHXManageUserViewController.h"
#import "PHXViewUserViewController.h"

static NSString * const PHXManageUserSegue = @"ManageUser";
static NSString * const PHXViewUserSegue = @"ViewUser";

@interface PHXIdentityModuleViewController()

@property (nonatomic, strong) PHXUser *user;

@end


@implementation PHXIdentityModuleViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:PHXManageUserSegue]) {
        PHXManageUserViewController *manageUser = segue.destinationViewController;
        manageUser.user = self.user;
    }
    else if ([segue.identifier isEqualToString:PHXViewUserSegue]) {
        PHXViewUserViewController *viewUser = segue.destinationViewController;
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
        
        [PHXPhoenixManager.phoenix.identity loginWithUsername:username password:password callback:^(PHXUser * _Nullable user, NSError * _Nullable error) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                if (error != nil) {
                    UIApplication *application = UIApplication.sharedApplication;
                    AppDelegate *delegate = application.delegate;
                    
                    [delegate alertWithMessage:@"Login Failed"];
                }
                else {
                    self.user = user;
                    [strongSelf performSegueWithIdentifier:PHXManageUserSegue sender:strongSelf];
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
                                                          
                                                          [PHXPhoenixManager.phoenix.identity getUser:[userId integerValue] callback:^(PHXUser * _Nullable user, NSError * _Nullable error) {
                                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                                  __strong typeof(weakSelf) strongSelf = weakSelf;
                                                                  
                                                                  if (user != nil && strongSelf != nil) {
                                                                      strongSelf.user = user;
                                                                      
                                                                      [strongSelf performSegueWithIdentifier:PHXViewUserSegue sender:strongSelf];
                                                                  }
                                                              });
                                                          }];
                                                      }]];
    
    [self presentViewController:alertController animated:true completion:nil];
}

- (IBAction)unwindOnLogout:(UIStoryboardSegue *)segue {
    
}

@end
