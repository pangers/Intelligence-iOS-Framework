//
//  PHXPhoenixManager.h
//  PhoenixDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import <Foundation/Foundation.h>

@import PhoenixSDK

@interface PHXPhoenixManager : NSObject

+(instancetype) sharedManager;

@property(nonatomic,readonly,strong) Phoenix* phoenix;

-(void) startup;

@end
