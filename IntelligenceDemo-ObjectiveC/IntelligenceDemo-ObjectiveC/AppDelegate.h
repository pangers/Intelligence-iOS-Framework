//
//  AppDelegate.h
//  IntelligenceDemo-ObjectiveC
//
//  Created by Rui Silvestre on 20/07/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const IntelligenceDemoStoredDeviceTokenKey;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)alertWithError:(NSError *)error;
- (void)alertWithMessage:(NSString*)message;

@end

