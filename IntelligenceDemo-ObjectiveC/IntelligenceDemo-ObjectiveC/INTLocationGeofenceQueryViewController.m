//
//  INTLocationGeofenceQueryViewController.m
//  IntelligenceDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 06/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "INTLocationGeofenceQueryViewController.h"

@interface UITextField (Numeric)

-(nullable NSNumber*) int_number;

@end

@implementation UITextField (Numeric)

-(nullable NSNumber*) int_number
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    return [f numberFromString:self.text];
}

@end

@interface INTLocationGeofenceQueryViewController ()

@property (weak, nonatomic) IBOutlet UITextField *latitudeText;
@property (weak, nonatomic) IBOutlet UITextField *longitudeText;
@property (weak, nonatomic) IBOutlet UITextField *pageSizeText;
@property (weak, nonatomic) IBOutlet UITextField *pageText;
@property (weak, nonatomic) IBOutlet UITextField *radiusText;

@property (strong, nonatomic) IBOutlet UIView *accessoryView;

@end

@implementation INTLocationGeofenceQueryViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignResponders)]];
    
    self.latitudeText.text = [NSString stringWithFormat:@"%@",@(self.latitude)];
    self.longitudeText.text = [NSString stringWithFormat:@"%@",@(self.longitude)];
    
    NSArray<UITextField*>* textFields = @[self.latitudeText, self.longitudeText, self.pageSizeText, self.pageText, self.radiusText];
    [textFields makeObjectsPerformSelector:@selector(setInputAccessoryView:)
                                withObject:self.accessoryView];

}

-(void) resignResponders
{
    NSArray<UITextField*>* textFields = @[self.latitudeText, self.longitudeText, self.pageSizeText, self.pageText, self.radiusText];
    [textFields makeObjectsPerformSelector:@selector(resignFirstResponder)];
}

- (IBAction)didTapSave:(id)sender {
    [self resignResponders];
    if ( [self.delegate respondsToSelector:@selector(didSelectGeofenceQuery:)] )
    {
        double latitude;
        
        if (self.latitudeText.int_number != nil) {
            latitude = [self.latitudeText.int_number doubleValue];
        }
        else {
            latitude = 0;
        }
        
        
        double longitude;
        
        if (self.longitudeText.int_number != nil) {
            longitude = [self.longitudeText.int_number doubleValue];
        }
        else {
            longitude = 0;
        }
        
        
        double radius;
        
        if (self.radiusText.int_number != nil) {
            radius = [self.radiusText.int_number doubleValue];
        }
        else {
            radius = 40075000; // The circumference of the Earth
        }
        
        
        INTCoordinate* coordinate = [[INTCoordinate alloc] initWithLatitude:latitude
                                                                  longitude:longitude];
        
        INTGeofenceQuery* query = [[INTGeofenceQuery alloc] initWithLocation:coordinate radius:radius];
        
        if (self.pageSizeText.int_number != nil) {
            [query setPageSize:[self.pageSizeText.int_number integerValue]];
        }
        
        if (self.pageText.int_number != nil) {
            [query setPage:[self.pageText.int_number integerValue]];
        }
        
        
        [self.delegate didSelectGeofenceQuery:query];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapCancel:(id)sender {
    [self resignResponders];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
