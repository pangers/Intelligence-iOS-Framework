//
//  PHXLocationGeofenceQueryViewController.h
//  IntelligenceDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 06/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import <UIKit/UIKit.h>

@import IntelligenceSDK;

@protocol PHXGeofenceQueryBuilderDelegate <NSObject>

-(void) didSelectGeofenceQuery:(PHXGeofenceQuery*)query;

@end

@interface PHXLocationGeofenceQueryViewController : UIViewController

@property(nonatomic,weak) id<PHXGeofenceQueryBuilderDelegate> delegate;

@property(nonatomic) double latitude;
@property(nonatomic) double longitude;

@end
