//
//  AppDelegate.h
//  Intelligence
//
//  Created by chethan.palaksha on 19/4/17.
//  Copyright © 2017 TigerSpike. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const IntelligenceDemoStoredDeviceTokenKey;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)alertWithError:(NSError *)error;
- (void)alertWithMessage:(NSString*)message;

@end

