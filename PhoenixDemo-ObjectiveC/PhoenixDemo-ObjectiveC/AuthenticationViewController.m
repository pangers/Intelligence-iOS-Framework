//
//  AuthenticationViewController.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Chris Nevin on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "AuthenticationViewController.h"

@import PhoenixSDK;

#import "PHXPhoenixManager.h"

typedef NS_ENUM(NSUInteger) {
    Login,
    LoggedIn,
    LoggingIn,
    LoginFailed,
} LoginMessage;

@interface AuthenticationViewController()
{
    LoginMessage currentStatus;
}
@end


@implementation AuthenticationViewController

- (LoginMessage)status {
    if ([self loggedIn]) {
        return LoggedIn;
    } else {
        return currentStatus;
    }
}

- (NSString*)messageForStatus {
    switch ([self status]) {
        case LoggedIn:
            return @"Logged in";
        case Login:
            return @"Login";
        case LoggingIn:
            return @"Logging in...";
        case LoginFailed:
            return @"Login failed!";
        default:
            return @"";
    }
}

- (UIColor*)colorForStatus {
    switch ([self status]) {
        case LoggingIn:
            return [UIColor purpleColor];
        case LoggedIn:
            return [UIColor grayColor];
        case LoginFailed:
            return [UIColor redColor];
        default:
            return [UIColor blackColor];
    }
}

- (Phoenix*)phoenix {
    return [[PHXPhoenixManager sharedManager] phoenix];
}

- (BOOL)loggedIn {
    return [[self phoenix] isLoggedIn];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Authentication"];
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
    
    currentStatus = LoggingIn;
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
            currentStatus = Login;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
            }];
            return;
        }
        [self.phoenix loginWithUsername:username password:password callback:^(BOOL authenticated) {
            currentStatus = authenticated ? LoggedIn : LoginFailed;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
            }];
        }];
    }]];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)logout {
    currentStatus = Login;
    [self.phoenix logout];
    [self.tableView reloadData];
}

@end
