//
//  INTIntelligenceManager.m
//  IntelligenceDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "INTIntelligenceManager.h"

@interface INTIntelligenceManager()

@property (nonatomic) Intelligence* intelligence;

@end

@implementation INTIntelligenceManager

+ (instancetype)sharedInstance {
    static INTIntelligenceManager* instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[INTIntelligenceManager alloc] init];
    });
    
    return instance;
}

+(void) setupIntelligence:(Intelligence*)intelligence {
    [INTIntelligenceManager sharedInstance].intelligence = intelligence;
}

+ (Intelligence*)intelligence {
    return [[self sharedInstance] intelligence];
}

@end
