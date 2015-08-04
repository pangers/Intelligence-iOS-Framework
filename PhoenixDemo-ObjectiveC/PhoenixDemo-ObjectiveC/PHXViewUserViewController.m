//
//  PHXViewUserViewController.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXViewUserViewController.h"

@interface PHXViewUserViewController ()

@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *password;
@property (weak, nonatomic) IBOutlet UILabel *firstname;
@property (weak, nonatomic) IBOutlet UILabel *lastname;
@property (weak, nonatomic) IBOutlet UILabel *avatarURL;


@end

@implementation PHXViewUserViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self showUser];
}

-(void)setUser:(id<PHXPhoenixUser>)user
{
    _user = user;
    
    [self showUser];
}

-(void) showUser
{
    if ( self.idLabel == nil ) {
        return; // No views set
    }
    
    if ( self.user == nil ) {
        return; // No user set
    }
    
    self.idLabel.text = [NSString stringWithFormat:@"User Id: %d", (int) self.user.userId];
    self.username.text = [NSString stringWithFormat:@"Username: %@", self.user.username];
    self.password.text = [NSString stringWithFormat:@"Password: %@", self.user.password];
    self.firstname.text = [NSString stringWithFormat:@"Firstname: %@", self.user.firstName];
    self.lastname.text = [NSString stringWithFormat:@"Lastname: %@", self.user.lastName];
    self.avatarURL.text = [NSString stringWithFormat:@"Avatar url: %@", self.user.avatarURL];
}

@end
