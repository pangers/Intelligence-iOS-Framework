//
//  PHXAuthenticationViewController.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Chris Nevin on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXAuthenticationViewController.h"
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

@interface PHXAuthenticationViewController()
{
    PHXLoginMessage currentStatus;
    PHXUser *loggedInUser;
    BOOL isLoggedIn;
}
@end


@implementation PHXAuthenticationViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:ViewUserSegue]) {
        PHXViewUserViewController *viewUser = segue.destinationViewController;
        viewUser.user = loggedInUser;
        loggedInUser = nil;
    }
}

- (PHXLoginMessage)status {
    if ([self loggedIn]) {
        return PHXLoggedIn;
    } else {
        return currentStatus;
    }
}

- (NSString*)messageForStatus {
    switch ([self status]) {
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
    switch ([self status]) {
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

- (BOOL)loggedIn {
    return false;// [PHXPhoenixManager.phoenix.identity isLoggedIn];
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
        cell.userInteractionEnabled = !self.loggedIn;
    } else {
        cell.textLabel.text = @"Logout";
        cell.textLabel.textColor = !self.loggedIn ? [UIColor grayColor] : [UIColor blackColor];
        cell.userInteractionEnabled = self.loggedIn;
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
    
    if (self.loggedIn) { return; }
    
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
        [PHXPhoenixManager.phoenix.identity loginWithUsername:username password:password callback:^(NSError * _Nullable error) {
            currentStatus = self.loggedIn ? PHXLoggedIn : PHXLoginFailed;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
                if (currentStatus == PHXLoggedIn) {
                    //loggedInUser = user;
                    isLoggedIn = error == nil;
                    [self performSegueWithIdentifier:ViewUserSegue sender:self];
                }
            }];
        }];
    }]];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)logout {
    currentStatus = PHXLogin;
    [PHXPhoenixManager.phoenix.identity logout];
    [self.tableView reloadData];
}

@end
