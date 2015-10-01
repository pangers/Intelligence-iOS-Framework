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
@property (nonatomic, strong) PHXUser *loggedInUser;
@property (nonatomic) PHXLoginMessage currentStatus;
@property (nonatomic) BOOL isLoggedIn;
@end


@implementation PHXAuthenticationViewController

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:ViewUserSegue]) {
        PHXViewUserViewController *viewUser = segue.destinationViewController;
        viewUser.user = self.loggedInUser;
        self.loggedInUser = nil;
    }
}

- (PHXLoginMessage)status {
    if (self.isLoggedIn) {
        return PHXLoggedIn;
    } else {
        return self.currentStatus;
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
    self.currentStatus = PHXLoggingIn;
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
            weakSelf.currentStatus = PHXLogin;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
            }];
            return;
        }
        [PHXPhoenixManager.phoenix.identity loginWithUsername:username password:password callback:^(NSError * _Nullable error) {
            weakSelf.isLoggedIn = error == nil;
            weakSelf.currentStatus = weakSelf.isLoggedIn ? PHXLoggedIn : PHXLoginFailed;
            if (weakSelf.isLoggedIn) {
                [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                    [weakSelf.tableView reloadData];
                    [PHXPhoenixManager.phoenix.identity getMe:^(PHXUser * _Nullable user, NSError * _Nullable error) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            if (user) {
                                __strong typeof(weakSelf) strongSelf = weakSelf;
                                strongSelf.loggedInUser = user;
                                [strongSelf performSegueWithIdentifier:ViewUserSegue sender:strongSelf];
                            } else {
                                NSLog(@"Error : %@", error);
                            }
                        }];
                    }];
                }];
            }
        }];
    }]];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)logout {
    self.currentStatus = PHXLogin;
    [PHXPhoenixManager.phoenix.identity logout];
    [self.tableView reloadData];
}

@end
