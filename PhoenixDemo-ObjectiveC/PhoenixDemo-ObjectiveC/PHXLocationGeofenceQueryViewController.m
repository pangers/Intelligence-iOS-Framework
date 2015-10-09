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
@property (weak, nonatomic) IBOutlet UITextField *sortByText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortDirectionSegmentedControl;

@property (strong, nonatomic) IBOutlet UIView *accessoryView;
@property (strong, nonatomic) IBOutlet UIPickerView *sortByPickerView;

@end

@implementation PHXLocationGeofenceQueryViewController

-(void)viewDidLoad {
    [super viewDidLoad];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(resignResponders)]];
    
    self.latitudeText.text = [NSString stringWithFormat:@"%@",@(self.latitude)];
    self.longitudeText.text = [NSString stringWithFormat:@"%@",@(self.longitude)];
    self.sortByText.inputView = self.sortByPickerView;
    self.sortByText.text = @"Distance";
    
    NSArray<UITextField*>* textFields = @[self.latitudeText, self.longitudeText, self.pageSizeText, self.pageText, self.radiusText, self.sortByText];
    [textFields makeObjectsPerformSelector:@selector(setInputAccessoryView:)
                                withObject:self.accessoryView];

}

-(void) resignResponders
{
    NSArray<UITextField*>* textFields = @[self.latitudeText, self.longitudeText, self.pageSizeText, self.pageText, self.radiusText, self.sortByText];
    [textFields makeObjectsPerformSelector:@selector(resignFirstResponder)];
}

-(GeofenceSortCriteria) sortingCriteriaInRow:(NSInteger)row {
    switch ( row ) {
        case GeofenceSortCriteriaAddress:
        case GeofenceSortCriteriaDescription:
        case GeofenceSortCriteriaDistance:
        case GeofenceSortCriteriaId:
        case GeofenceSortCriteriaName:
        case GeofenceSortCriteriaReference:
            return row;
    }
    NSAssert(false, @"Should never have a value not in GeofenceSortCriteria.");
    return GeofenceSortCriteriaDistance;
}

- (IBAction)didTapSave:(id)sender {
    [self resignResponders];
    if ( [self.delegate respondsToSelector:@selector(didSelectGeofenceQuery:)] )
    {
        PHXCoordinate* coordinate = [[PHXCoordinate alloc] initWithLatitude:self.latitudeText.phx_double
                                                                  longitude:self.longitudeText.phx_double];
        
        PHXGeofenceQuery* query = [[PHXGeofenceQuery alloc] initWithLocation:coordinate];
        [query setRadius:self.radiusText.phx_double == 0 ? 1000.0 : self.radiusText.phx_double];
        [query setPage:self.pageText.phx_integer == 0 ? 0 : self.pageText.phx_integer];
        [query setPageSize:self.pageSizeText.phx_integer == 0 ? 10 : self.radiusText.phx_integer];
        [query setSortingDirection:self.sortDirectionSegmentedControl.selectedSegmentIndex == 1 ? GeofenceSortDirectionAscending : GeofenceSortDirectionDescending];
        [query setSortingCriteria:[self sortingCriteriaInRow:[self.sortByPickerView selectedRowInComponent:0]]];
        [self.delegate didSelectGeofenceQuery:query];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)didTapCancel:(id)sender {
    [self resignResponders];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end

#pragma mark - UIPickerViewDelegate and UIPickerViewDataSource

@interface PHXLocationGeofenceQueryViewController (PickerViewDatasource) <UIPickerViewDelegate, UIPickerViewDataSource>
@end

@implementation PHXLocationGeofenceQueryViewController (PickerViewDatasource)

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 6;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch ( row ) {
        case GeofenceSortCriteriaAddress:
            return @"Address";
            
        case GeofenceSortCriteriaDescription:
            return @"Description";
            
        case GeofenceSortCriteriaDistance:
            return @"Distance";
            
        case GeofenceSortCriteriaId:
            return @"Id";
            
        case GeofenceSortCriteriaName:
            return @"Name";
            
        case GeofenceSortCriteriaReference:
            return @"Reference";
    }
    NSAssert(false, @"Should never have a value not in GeofenceSortCriteria.");
    return @"";
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.sortByText.text = [self pickerView:pickerView titleForRow:row forComponent:component];
}

@end
