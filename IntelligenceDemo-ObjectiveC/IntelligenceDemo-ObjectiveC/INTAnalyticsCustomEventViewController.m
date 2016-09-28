//
//  INTAnalyticsCustomEventViewController.m
//  IntelligenceDemo-ObjectiveC
//
//  Created by Shan Haq on 3/31/16.
//  Copyright © 2016 Tigerspike. All rights reserved.
//

#import "INTAnalyticsCustomEventViewController.h"
#import "INTIntelligenceManager.h"

@import IntelligenceSDK;

@interface INTAnalyticsCustomEventViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtEventType;
@property (weak, nonatomic) IBOutlet UITextField *txtEventValue;

@end

@implementation INTAnalyticsCustomEventViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)btnTriggerEventClicked:(id)sender {
    
    NSString *eventType = self.txtEventType.text;
    NSString *eventValue = self.txtEventValue.text;
    
    if(eventType != nil && eventValue != nil) {
        INTEvent *event = [[INTEvent alloc] initWithType:eventType value:[eventValue doubleValue] targetId:nil metadata:nil];
        [INTIntelligenceManager.intelligence.analytics track:event];
    } else {
        UIAlertController *c = [UIAlertController alertControllerWithTitle:@"Enter Values" message:@"Enter Event Type and Event Value to trigger the event" preferredStyle:UIAlertControllerStyleAlert];
        [c addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
        [self presentViewController:c animated:YES completion:nil];
        
    }
    
}

@end
