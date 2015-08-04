//
//  PHXCreateUserViewController.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXCreateUserViewController.h"

@interface PHXCreateUserViewController ()

@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *firstName;
@property (weak, nonatomic) IBOutlet UITextField *lastName;
@property (weak, nonatomic) IBOutlet UITextField *avatarURL;


@end

@implementation PHXCreateUserViewController

- (IBAction)didTapCreateUser:(id)sender {
    NSString* username = self.username.text;
    NSString* password = self.password.text;
    NSString* firstname = self.firstName.text;
    NSString* lastname = self.lastName.text;
    NSString* avatarURL = self.avatarURL.text;
    
    [[PHXPhoenixManager sharedManager].phoenix.identity]
}

@end
