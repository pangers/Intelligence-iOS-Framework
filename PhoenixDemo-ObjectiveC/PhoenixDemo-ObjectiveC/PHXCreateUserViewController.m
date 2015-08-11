//
//  PHXCreateUserViewController.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXCreateUserViewController.h"

#import "PHXPhoenixManager.h"
#import "PHXViewUserViewController.h"

@interface PHXCreateUserViewController ()

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *avatarURL;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;

@property (strong, nonatomic) PHXPhoenixUser* lastCreatedUser;

@end

@implementation PHXCreateUserViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showProgress:NO];
}

- (IBAction)didTapCreateUser:(id)sender {
    NSString* username = self.username.text;
    NSString* password = self.password.text;
    NSString* firstname = self.firstName.text;
    NSString* lastname = self.lastName.text;
    NSString* avatarURL = self.avatarURL.text;
    
    PHXConfiguration *configuration = [[PHXPhoenixManager sharedManager].phoenix currentConfiguration];
    NSInteger companyID = configuration.companyId;
    
    PHXPhoenixUser* user = [[PHXPhoenixUser alloc] initWithCompanyId:companyID username:username password:password firstName:firstname lastName:lastname avatarURL:avatarURL];
    
    [self showProgress:YES];
    
    __weak typeof(self) weakSelf = self;
    
    [[PHXPhoenixManager sharedManager].phoenix.identity createUser:user callback:^(PHXPhoenixUser* _Nullable user, NSError * _Nullable error) {
        [weakSelf showProgress:NO];

        if ( error != nil ) {
            [weakSelf createUserError:error.description];
            return;
        }
        
        if ( user == nil ) {
            [weakSelf createUserError:@"No user obtained"];
            return;
        }
        
        weakSelf.lastCreatedUser = user;
        NSString* message = [NSString stringWithFormat:@"New user created with id %d", (int) user.userId];
        [weakSelf showAlertWithTitle:@"User created" withMessage:message extraAction:[weakSelf createActionShowUser:user]];
    }];
}

- (void) showProgress:(BOOL)show {
    __weak typeof(self) weakSelf = self;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        weakSelf.view.userInteractionEnabled = !show;
        weakSelf.spinner.hidden = !show;
    });
}

- (void) createUserError:(NSString*)message {
    [self showAlertWithTitle:@"Error creating user" withMessage:message];
}

- (void) showAlertWithTitle:(NSString*) title withMessage:(NSString*) message {
    [self showAlertWithTitle:title withMessage:message extraAction:nil];
}

- (void) showAlertWithTitle:(NSString*) title withMessage:(NSString*) message extraAction:(UIAlertAction*)action
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController* controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        // Add dismiss action
        [controller addAction:[UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [controller dismissViewControllerAnimated:YES completion:nil];
        }]];
        
        if ( action != nil )
        {
            [controller addAction:action];
        }
        
        [self presentViewController:controller animated:YES completion:nil];
    });
}

- (UIAlertAction*) createActionShowUser:(PHXPhoenixUser*)user
{
    __weak typeof(self) weakSelf = self;
    return [UIAlertAction actionWithTitle:@"View user" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [weakSelf performSegueWithIdentifier:@"showUser" sender:self];
        
    }];
}

- (void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender
{
    if ( [@"showUser" isEqualToString:segue.identifier] )
    {
        PHXViewUserViewController* viewUserViewController = (PHXViewUserViewController*) segue.destinationViewController;
        viewUserViewController.user = self.lastCreatedUser;
    }
}

@end
