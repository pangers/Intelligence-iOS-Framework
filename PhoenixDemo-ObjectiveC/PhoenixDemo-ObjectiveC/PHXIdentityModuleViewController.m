//
//  PHXIdentityModuleViewController.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Chris Nevin on 05/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXIdentityModuleViewController.h"
#import "PHXViewUserViewController.h"

@implementation PHXIdentityModuleViewController

- (void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(nullable id)sender {
    
    // If we are presenting `GetMe` segue, set `fetchMe` to true.
    if ([segue.identifier isEqualToString:@"GetMe"] && [segue.destinationViewController isKindOfClass:[PHXViewUserViewController class]]) {
        PHXViewUserViewController *viewController = segue.destinationViewController;
        [viewController setFetchMe:true];
    }
}

@end
