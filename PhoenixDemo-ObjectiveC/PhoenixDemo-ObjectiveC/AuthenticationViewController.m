//
//  AuthenticationViewController.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Chris Nevin on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "AuthenticationViewController.h"

@import PhoenixSDK;

@interface AuthenticationViewController() <PhoenixNetworkDelegate>

@property (nonatomic) Phoenix *phoenix;
@property (nonatomic) NSString *loginErrorMessage;

@end


@implementation AuthenticationViewController

- (void)authenticationFailed:(NSData * _Nullable)data response:(NSURLResponse * _Nullable)response error:(NSError * _Nullable)error {
    
}

- (void)rise {
    NSError *err;
    self.phoenix = [[Phoenix alloc] initWithFile:@"PhoenixConfiguration" inBundle:[NSBundle mainBundle] error:&err];
    if (nil != err) {
        // Handle error, developer needs to resolve any errors thrown here, these should not be visible to the user
        // and generally indicate that something has gone wrong and needs to be resolved.
        NSLog(@"Error initialising Phoenix: %zd", err.code);
    }
    NSParameterAssert(err == nil && self.phoenix != nil);
    self.phoenix.networkDelegate = self;
    [self.phoenix startupWithCallback:^(BOOL authenticated) {
        NSLog(@"Anonymous login %d", authenticated);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"Authentication"];
    [self rise];
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
        if (self.loginErrorMessage == nil) {
            cell.textLabel.text = self.phoenix.isLoggedIn == true ? @"Logged in" : @"Login";
        } else {
            cell.textLabel.text = self.loginErrorMessage;
        }
        cell.userInteractionEnabled = self.phoenix.isLoggedIn == false;
    } else {
        cell.textLabel.text = @"Logout";
        cell.userInteractionEnabled = self.phoenix.isLoggedIn == true;
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
    
    if (self.phoenix.isLoggedIn == true) { return; }
    
    self.loginErrorMessage = @"Logging in...";
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
            self.loginErrorMessage = nil;
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
            }];
            return;
        }
        [self.phoenix loginWithUsername:username password:password callback:^(BOOL authenticated) {
            if (!authenticated) {
                self.loginErrorMessage = @"Login failed";
            } else {
                self.loginErrorMessage = nil;
            }
            [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                [self.tableView reloadData];
            }];
        }];
    }]];
    [self presentViewController:alert animated:true completion:nil];
}

- (void)logout {
    [self.phoenix logout];
    [self.tableView reloadData];
}

@end
