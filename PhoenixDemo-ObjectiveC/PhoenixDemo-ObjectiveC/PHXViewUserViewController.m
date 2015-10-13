//
//  PHXViewUserViewController.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXViewUserViewController.h"
#import "PHXPhoenixManager.h"

@interface PHXViewUserViewController ()

@property (weak, nonatomic) IBOutlet UITextField *idLabel;
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UITextField *firstname;
@property (weak, nonatomic) IBOutlet UITextField *lastname;
@property (weak, nonatomic) IBOutlet UITextField *avatarURL;

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation PHXViewUserViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self showUser];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tappedScreen:)]];
}

- (void)tappedScreen:(UITapGestureRecognizer*)tap {
    for (UITextField *field in @[_username, _password, _firstname, _lastname, _avatarURL]) {
        if ([field isFirstResponder]) { [field resignFirstResponder]; }
    }
}


-(void)setUser:(PHXUser*)user
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
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.idLabel.text = [NSString stringWithFormat:@"%d", (int) self.user.userId];
        self.username.text = self.user.username;
        self.password.text = self.user.password;
        self.firstname.text = self.user.firstName;
        self.lastname.text = self.user.lastName;
        self.avatarURL.text = self.user.avatarURL;
    });
}

-(void) showInformation:(NSString*) info{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!info) {
            self.infoLabel.text = @" ";
        }
        else {
            self.infoLabel.text = info;
        }
    });
}

-(id<PhoenixIdentity>) phoenixIdentity {
    return PHXPhoenixManager.phoenix.identity;
}

- (IBAction)didTapUpdateUser:(id)sender {
    self.user.username = self.username.text;
    self.user.password = self.password.text;
    self.user.firstName = self.firstname.text;
    self.user.lastName = self.lastname.text;
    self.user.avatarURL = self.avatarURL.text;
    
    [[self phoenixIdentity] updateUser:self.user callback:^(PHXUser * _Nullable user, NSError * _Nullable error) {
        if (user)
        {
            self.user = user;
            [self showInformation:@" "];
        }
        else
        {
            [self showInformation:[NSString stringWithFormat:@"There was an error while getting the user: %@", error]];
        }
    }];
}

@end
