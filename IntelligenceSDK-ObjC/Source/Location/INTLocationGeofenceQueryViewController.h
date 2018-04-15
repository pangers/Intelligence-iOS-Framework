//
//  INTLocationGeofenceQueryViewController.h
//  IntelligenceDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 06/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import <UIKit/UIKit.h>

@import IntelligenceSDK;

@protocol INTGeofenceQueryBuilderDelegate <NSObject>

-(void) didSelectGeofenceQuery:(INTGeofenceQuery*)query;

@end

@interface INTLocationGeofenceQueryViewController : UIViewController

@property(nonatomic,weak) id<INTGeofenceQueryBuilderDelegate> delegate;

@property(nonatomic) double latitude;
@property(nonatomic) double longitude;

@end
