//
//  PHXViewUserViewController.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXViewUserViewController.h"
#import "PHXPhoenixManager.h"

@interface PHXViewUserViewController () <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UILabel *idLabel;
@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *password;
@property (weak, nonatomic) IBOutlet UILabel *firstname;
@property (weak, nonatomic) IBOutlet UILabel *lastname;
@property (weak, nonatomic) IBOutlet UILabel *avatarURL;

@property (weak, nonatomic) IBOutlet UILabel *infoLabel;

@end

@implementation PHXViewUserViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    
    [self showUser];
    
    if ([self fetchMe]) {
        __weak typeof(self) weakSelf = self;

        [[self phoenixIdentity] getMe:^(PHXPhoenixUser* _Nullable user, NSError * _Nullable error) {
            [weakSelf showMe:user error:error];
        }];
    }
}

-(Phoenix*) phoenix {
    return [PHXPhoenixManager sharedManager].phoenix;
}

-(id<PhoenixIdentity>) phoenixIdentity {
    return [self phoenix].identity;
}

-(void)setUser:(PHXPhoenixUser*)user
{
    _user = user;
    
    [self showUser];
}

- (void) showMe:(PHXPhoenixUser*)user error:(NSError*)error {
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self setUser:user];
        if (error != nil) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:error.description preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
            [self presentViewController:alert animated:true completion:nil];
        }
    }];
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
        self.idLabel.text = [NSString stringWithFormat:@"User Id: %d", (int) self.user.userId];
        self.username.text = [NSString stringWithFormat:@"Username: %@", self.user.username];
        self.password.text = [NSString stringWithFormat:@"Password: %@", self.user.password];
        self.firstname.text = [NSString stringWithFormat:@"Firstname: %@", self.user.firstName];
        self.lastname.text = [NSString stringWithFormat:@"Lastname: %@", self.user.lastName];
        self.avatarURL.text = [NSString stringWithFormat:@"Avatar url: %@", self.user.avatarURL];        
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

-(void)searchBarSearchButtonClicked:(nonnull UISearchBar *)searchBar
{
    NSInteger userId = [[[NSNumberFormatter alloc] init] numberFromString:searchBar.text].integerValue;
    [searchBar resignFirstResponder];
    
    [[self phoenixIdentity] getUser:userId callback:^(PHXPhoenixUser * _Nullable user, NSError * _Nullable error) {
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
