//
//  INTStartupViewController.m
//  IntelligenceDemo-ObjectiveC
//
//  Created by Chris Nevin on 18/02/2016.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

#import "INTStartupViewController.h"

@implementation INTStartupViewController

- (void)setState:(INTStartupState)state {
    _state = state;
    switch (state) {
        case INTStartupStateStarting:
            self.loadingLabel.text = @"Wait while we startup Intelligence...";
            break;
        case INTStartupStateStarted:
            [self performSegueWithIdentifier:@"intelligenceStartedUp" sender:self];
            break;
        case INTStartupStateFailed:
            self.loadingLabel.text = @"Unable to startup Intelligence.";
            break;
    }
}

@end
