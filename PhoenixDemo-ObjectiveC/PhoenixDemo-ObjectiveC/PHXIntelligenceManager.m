//
//  PHXIntelligenceManager.m
//  IntelligenceDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 04/08/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXIntelligenceManager.h"

@interface PHXIntelligenceManager()

@property (nonatomic) Intelligence* intelligence;

@end

@implementation PHXIntelligenceManager

+ (instancetype)sharedInstance {
    static PHXIntelligenceManager* instance;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[PHXIntelligenceManager alloc] init];
    });
    
    return instance;
}

+(void) setupIntelligence:(Intelligence*)intelligence {
    [PHXIntelligenceManager sharedInstance].intelligence = intelligence;
}

+ (Intelligence*)intelligence {
    return [[self sharedInstance] intelligence];
}

@end
