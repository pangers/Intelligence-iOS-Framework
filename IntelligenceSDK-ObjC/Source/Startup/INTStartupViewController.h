//
//  INTStartupViewController.h
//  IntelligenceDemo-ObjectiveC
//
//  Created by Chris Nevin on 18/02/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, INTStartupState) {
    INTStartupStateStarting = 0,
    INTStartupStateStarted,
    INTStartupStateFailed,
};

@interface INTStartupViewController : UIViewController

@property (nonatomic, weak) IBOutlet UILabel *loadingLabel;
@property (nonatomic) INTStartupState state;

@end
