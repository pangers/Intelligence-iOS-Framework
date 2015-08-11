//
//  PHXViewUserViewController.h
//  PhoenixDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import <UIKit/UIKit.h>

@import PhoenixSDK;

@interface PHXViewUserViewController : UIViewController

@property (strong, nonatomic) PHXPhoenixUser* user;
@property BOOL fetchMe;

@end
