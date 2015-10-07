//
//  PHXPhoenixManager.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXPhoenixManager.h"

@interface PHXPhoenixManager() <PHXPhoenixDelegate>

@property (nonatomic) Phoenix* phoenix;

@end

@implementation PHXPhoenixManager

+ (instancetype)sharedInstance {
    static PHXPhoenixManager* instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PHXPhoenixManager alloc] init];
    });
    
    return instance;
}

+(void) setupPhoenix:(Phoenix*)phoenix {
    [PHXPhoenixManager sharedInstance].phoenix = phoenix;
}

+ (Phoenix*)phoenix {
    return [[self sharedInstance] phoenix];
}

- (void)userCreationFailedForPhoenix:(Phoenix *)phoenix {
    NSLog(@"Unrecoverable error occurred during user creation, check Phoenix Intelligence accounts are configured correctly.");
}

- (void)userLoginRequiredForPhoenix:(Phoenix *)phoenix {
    NSLog(@"Present login screen or call identity.login with credentials stored in Keychain.");
}

- (void)userRoleAssignmentFailedForPhoenix:(Phoenix *)phoenix {
    NSLog(@"Unrecoverable error occurred during user role assignment, if this happens consistently please confirm that Phoenix Intelligence accounts are configured correctly.");
}

@end
