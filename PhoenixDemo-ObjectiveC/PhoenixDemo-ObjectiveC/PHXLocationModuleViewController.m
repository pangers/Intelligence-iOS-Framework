//
//  PHXLocationModuleViewController.m
//  PhoenixDemo-ObjectiveC
//
//  Created by Josep Rodriguez on 06/10/2015.
//  Copyright © 2015 Tigerspike. All rights reserved.
//

#import "PHXLocationModuleViewController.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
@import PhoenixSDK;

#import "PHXPhoenixManager.h"
#import "PHXLocationGeofenceQueryViewController.h"

@interface PHXLocationModuleViewController () <PHXLocationDelegate,PHXGeofenceQueryBuilderDelegate, UITableViewDataSource, MKMapViewDelegate>

@property(nonatomic, strong) NSArray<NSString*>* events;
@property(nonatomic, strong) CLLocationManager* locationManager;
@property(nonatomic, strong) NSArray<PHXGeofence*>* lastDownloadedGeofences;
@property(nonatomic, strong) NSTimer* timer;

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *monitoringButton;

@end

@implementation PHXLocationModuleViewController

static NSString* const cellIdentifier = @"cell";

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.events = @[];
    
    self.locationManager = [[CLLocationManager alloc] init];
    
    [PHXPhoenixManager phoenix].location.delegate = self;
    
    // Using the best kind of accuracy for demo purposes.
    [[PHXPhoenixManager phoenix].location setLocationAccuracy:kCLLocationAccuracyBest];
}

-(void)dealloc {
    [[PHXPhoenixManager phoenix].location stopMonitoringGeofences];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(refreshGeofences) userInfo:nil repeats:YES];
    
    CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
    if ( status != kCLAuthorizationStatusAuthorizedAlways && status != kCLAuthorizationStatusAuthorizedWhenInUse ) {
        [self.locationManager requestAlwaysAuthorization];
    }
    
    [self.mapView setUserTrackingMode:MKUserTrackingModeFollow];
    [self.tableView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    [super prepareForSegue:segue sender:sender];
    
    if ( [@"download" isEqualToString:segue.identifier] )
    {
        PHXLocationGeofenceQueryViewController* vc = (PHXLocationGeofenceQueryViewController*) segue.destinationViewController;
        vc.latitude = self.locationManager.location.coordinate.latitude;
        vc.longitude = self.locationManager.location.coordinate.longitude;
        vc.delegate = self;
    }
}

- (IBAction)didTapMonitoringButton:(id)sender {
    id<PHXLocation> locationModule = PHXPhoenixManager.phoenix.location;
    
    if ( [locationModule isMonitoringGeofences] )
    {
        [locationModule stopMonitoringGeofences];
        [self logEvent:@"Stopped monitoring"];
        [self.monitoringButton setTitle:@"Enable monitoring" forState:UIControlStateNormal];
    }
    else
    {
        if ( self.lastDownloadedGeofences.count == 0 ) {
            [self logEvent:@"No geofences available."];
        }
        else
        {
            [locationModule startMonitoringGeofences:self.lastDownloadedGeofences];
            [self displayGeofences:self.lastDownloadedGeofences];
            [self logEvent:@"Started monitoring"];
            [self.monitoringButton setTitle:@"Disable monitoring" forState:UIControlStateNormal];
        }
    }
    
    [self refreshGeofences];
}

-(void)didSelectGeofenceQuery:(PHXGeofenceQuery *)query {
    id<PHXLocation> locationModule = PHXPhoenixManager.phoenix.location;
    [locationModule downloadGeofences:query callback:^(NSArray<PHXGeofence *>* _Nullable geofences, NSError*  _Nullable error) {
        
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [self didReceiveGeofences:geofences error:error];
        }];
        
    }];
}

-(void) didReceiveGeofences:(NSArray<PHXGeofence*>*)geofences error:(NSError*) error {
    id<PHXLocation> locationModule = PHXPhoenixManager.phoenix.location;

    if ( error != nil ) {
        [self logEvent:@"Error occured while downloading geofences"];
    }
    else if ( geofences.count == 0 )
    {
        [self logEvent:@"No geofences fetched"];
    }
    else
    {
        self.lastDownloadedGeofences = geofences;
        
        [self refreshGeofences];
        
        if ( [locationModule isMonitoringGeofences] )
        {
            [locationModule startMonitoringGeofences:geofences];
        }
        
        [self logEvent:@"Fetched geofences"];
    }
}

-(void)phoenixLocation:(id<PHXLocation>)location didEnterGeofence:(PHXGeofence *)geofence
{
    [self logEvent:[NSString stringWithFormat:@"Entered %@", geofence.name]];
}

-(void)phoenixLocation:(id<PHXLocation>)location didExitGeofence:(PHXGeofence *)geofence
{
    [self logEvent:[NSString stringWithFormat:@"Exited %@", geofence.name]];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.events.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.text = self.events[self.events.count - 1 - indexPath.row];
    return cell;
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay
{
    NSAssert([overlay isKindOfClass:MKCircle.class], @"Expected an MKCircle as overlay, got a %@ instead.", overlay.class);
    MKCircleRenderer* renderer = [[MKCircleRenderer alloc] initWithCircle:overlay];
    UIColor* color = [[PHXPhoenixManager phoenix].location isMonitoringGeofences] ? UIColor.greenColor : UIColor.redColor;
    
    renderer.fillColor = [color colorWithAlphaComponent:0.4];
    renderer.strokeColor = color;
    renderer.lineWidth = 2;
    return renderer;
}

-(void) logEvent:(NSString*)event
{
    self.events = [self.events arrayByAddingObject:event];
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        [self.tableView reloadData];
    }];
}

-(void) refreshGeofences
{
    if ( self.lastDownloadedGeofences != nil )
    {
        [self displayGeofences:self.lastDownloadedGeofences];
    }
}

-(void) displayGeofences:(NSArray<PHXGeofence*>*) geofences {
    [self.mapView removeOverlays:self.mapView.overlays];
    
    for ( PHXGeofence* geofence in geofences )
    {
        CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake(geofence.latitude, geofence.longitude);
        MKCircle* circle = [MKCircle circleWithCenterCoordinate:coordinates radius:geofence.radius];
        [self.mapView addOverlay:circle];
    }
}

@end
