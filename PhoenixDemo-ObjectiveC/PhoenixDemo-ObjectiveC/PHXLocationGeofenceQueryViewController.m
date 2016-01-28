//
//  PHXLocationGeofenceQueryViewController.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 06/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXLocationGeofenceQueryViewController.h"

@interface UITextField (Numeric)

-(nullable NSNumber*) phx_number;

@end

@implementation UITextField (Numeric)

-(nullable NSNumber*) phx_number
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    return [f numberFromString:self.text];
}

@end

@interface PHXLocationGeofenceQueryViewController ()

@property (weak, nonatomic) IBOutlet UITextField *latitudeText;
@property (weak, nonatomic) IBOutlet UITextField *longitudeText;
@property (weak, nonatomic) IBOutlet UITextField *pageSizeText;
@property (weak, nonatomic) IBOutlet UITextField *pageText;
@property (weak, nonatomic) IBOutlet UITextField *radiusText;

@property (strong, nonatomic) IBOutlet UIView *accessoryView;

@end

@implementation PHXLocationGeofenceQueryViewController

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
        
        if (self.latitudeText.phx_number != nil) {
            latitude = [self.latitudeText.phx_number doubleValue];
        }
        else {
            latitude = 0;
        }
        
        
        double longitude;
        
        if (self.longitudeText.phx_number != nil) {
            longitude = [self.longitudeText.phx_number doubleValue];
        }
        else {
            longitude = 0;
        }
        
        
        double radius;
        
        if (self.radiusText.phx_number != nil) {
            radius = [self.radiusText.phx_number doubleValue];
        }
        else {
            radius = 40075000; // The circumference of the Earth
        }
        
        
        PHXCoordinate* coordinate = [[PHXCoordinate alloc] initWithLatitude:latitude
                                                                  longitude:longitude];
        
        PHXGeofenceQuery* query = [[PHXGeofenceQuery alloc] initWithLocation:coordinate radius:radius];
        
        if (self.pageSizeText.phx_number != nil) {
            [query setPageSize:[self.pageSizeText.phx_number integerValue]];
        }
        
        if (self.pageText.phx_number != nil) {
            [query setPage:[self.pageText.phx_number integerValue]];
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
