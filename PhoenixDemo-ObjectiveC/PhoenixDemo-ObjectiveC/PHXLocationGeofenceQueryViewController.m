//
//  PHXLocationGeofenceQueryViewController.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 06/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXLocationGeofenceQueryViewController.h"

@interface UITextField (Numeric)

-(double) phx_double;
-(NSInteger) phx_integer;

@end

@implementation UITextField (Numeric)

-(NSNumber*) phx_number
{
    NSNumberFormatter *f = [[NSNumberFormatter alloc] init];
    f.numberStyle = NSNumberFormatterDecimalStyle;
    NSNumber *myNumber = [f numberFromString:self.text];
    
    if ( myNumber == nil )
    {
        myNumber = @(0);
    }
    
    return myNumber;
}

-(double) phx_double
{
    return [self phx_number].doubleValue;
}

-(NSInteger) phx_integer
{
    return [self phx_number].integerValue;
}

@end

@interface PHXLocationGeofenceQueryViewController ()

@property (weak, nonatomic) IBOutlet UITextField *latitudeText;
@property (weak, nonatomic) IBOutlet UITextField *longitudeText;
@property (weak, nonatomic) IBOutlet UITextField *pageSizeText;
@property (weak, nonatomic) IBOutlet UITextField *pageText;
@property (weak, nonatomic) IBOutlet UITextField *radiusText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortDirectionSegmentedControl;

@end

@implementation PHXLocationGeofenceQueryViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapOnView)]];
    
    self.latitudeText.text = [NSString stringWithFormat:@"%@",@(self.latitude)];
    self.longitudeText.text = [NSString stringWithFormat:@"%@",@(self.longitude)];
}

-(void) didTapOnView
{
    [@[self.latitudeText, self.longitudeText, self.pageSizeText, self.pageText, self.radiusText] makeObjectsPerformSelector:@selector(resignFirstResponder)];
}

- (IBAction)didTapSave:(id)sender {
    if ( [self.delegate respondsToSelector:@selector(didSelectGeofenceQuery:)] )
    {
        PHXCoordinate* coordinate = [[PHXCoordinate alloc] initWithLatitude:self.latitudeText.phx_double
                                                                  longitude:self.longitudeText.phx_double];
        
        PHXGeofenceQuery* query = [[PHXGeofenceQuery alloc] initWithLocation:coordinate];
        [query setRadius:self.radiusText.phx_double == 0 ? 1000.0 : self.radiusText.phx_double];
        [query setPage:self.pageText.phx_integer == 0 ? 0 : self.pageText.phx_integer];
        [query setPageSize:self.pageSizeText.phx_integer == 0 ? 10 : self.radiusText.phx_integer];
        [query setSortingDirection:self.sortDirectionSegmentedControl.selectedSegmentIndex == 1 ? GeofenceSortDirectionAscending : GeofenceSortDirectionDescending];
        [self.delegate didSelectGeofenceQuery:query];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
