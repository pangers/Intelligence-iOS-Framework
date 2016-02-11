//
//  PHXIntelligenceManager.h
//  IntelligenceDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import <Foundation/Foundation.h>

@import IntelligenceSDK;

@interface PHXIntelligenceManager : NSObject

+ (void)setupIntelligence:(Intelligence*)intelligence;

+ (Intelligence *)intelligence;

@end
