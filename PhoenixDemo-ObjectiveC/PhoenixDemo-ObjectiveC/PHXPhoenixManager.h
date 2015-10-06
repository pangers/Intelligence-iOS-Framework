//
//  PHXPhoenixManager.h
//  PhoenixDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import <Foundation/Foundation.h>

@import PhoenixSDK;

@interface PHXPhoenixManager : NSObject

+ (void)setupPhoenix:(Phoenix*)phoenix;

+ (Phoenix *)phoenix;

@end
