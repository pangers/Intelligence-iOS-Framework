//
//  PHXAuthenticationViewController.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Chris Nevin on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXAuthenticationViewController.h"
#import "AppDelegate.h"
#import "PHXPhoenixManager.h"
#import "PHXViewUserViewController.h"

@import PhoenixSDK;

static NSString * const ViewUserSegue = @"LoginViewUser";

typedef NS_ENUM(NSUInteger, PHXLoginMessage) {
    PHXLogin,
    PHXLoggedIn,
    PHXLoggingIn,
    PHXLoginFailed,
};

@implementation PHXAuthenticationViewController

static PHXUser *loggedInUser;
static PHXLoginMessage currentStatus;

-(BOOL) isLoggedIn {
    return currentStatus == PHXLoggedIn;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:ViewUserSegue]) {
        PHXViewUserViewController *viewUser = segue.destinationViewController;
        viewUser.user = loggedInUser;
    }
}

- (NSString*)messageForStatus {
    switch (currentStatus) {
        case PHXLoggedIn:
            return @"Logged in";
        case PHXLogin:
            return @"Login";
        case PHXLoggingIn:
            return @"Logging in...";
        case PHXLoginFailed:
            return @"Login failed!";
        default:
            return @"";
    }
}

- (UIColor*)colorForStatus {
    switch (currentStatus) {
        case PHXLoggingIn:
            return [UIColor purpleColor];
        case PHXLoggedIn:
            return [UIColor grayColor];
        case PHXLoginFailed:
            return [UIColor redColor];
        default:
            return [UIColor blackColor];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Login"];
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(nonnull UITableView *)tableView {
    return 1;
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    if (indexPath.row == 0) {
        cell.textLabel.text = [self messageForStatus];
        cell.textLabel.textColor = [self colorForStatus];
        cell.userInteractionEnabled = !self.isLoggedIn;
    } else {
        cell.textLabel.text = @"Logout";
        cell.textLabel.textColor = !self.isLoggedIn ? [UIColor grayColor] : [UIColor blackColor];
        cell.userInteractionEnabled = self.isLoggedIn;
    }
    return cell;
}

- (void)tableView:(nonnull UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    if (indexPath.row == 0) {
        [self login];
    } else {
        [self logout];
    }
}

- (void)login {
    __weak typeof(self) weakSelf = self;
    currentStatus = PHXLoggingIn;
    [self.tableView reloadData];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Enter Details" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Username";
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Password";
        textField.secureTextEntry = true;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        currentStatus = PHXLogin;
        [self.tableView reloadData];
    }]];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Login" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        NSString *username = alert.textFields.firstObject.text;
        NSString *password = alert.textFields.lastObject.text;
        
        if (!(username.length != 0 && password.length != 0)) {
            currentStatus = PHXLogin;
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
            }];
            return;
        }
        
        
        [PHXPhoenixManager.phoenix.identity loginWithUsername:username password:password callback:^(PHXUser * _Nullable user, NSError * _Nullable error) {
            
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                
                __strong typeof(weakSelf) strongSelf = weakSelf;
                
                currentStatus = (error == nil) ? PHXLoggedIn : PHXLoginFailed;
                
                if (strongSelf.isLoggedIn) {
                    
                    [strongSelf.tableView reloadData];
                    
                    if (user) {
                        loggedInUser = user;
                        [strongSelf performSegueWithIdentifier:ViewUserSegue sender:strongSelf];
                    }
                    else {
                        NSLog(@"Error : %@", error);
                    }
                }
            }];
            
        }];
    }]];
    
    [self presentViewController:alert animated:true completion:nil];
}

- (void)logout {
    currentStatus = PHXLogin;
    [PHXPhoenixManager.phoenix.identity logout];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey: PhoenixDemoStoredDeviceTokenKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self.tableView reloadData];
}

@end
