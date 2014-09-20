//
//  PDLocationsMapViewController.m
//  LocationsMap
//
//  Created by Pradyumna Doddala on 25/12/12.
//  Copyright (c) 2012 Pradyumna Doddala. All rights reserved.
//

#import "PDLocationsMapViewController.h"
#import "PDLocation.h"
#import "MapPoint.h"

static CGRect MapOriginalFrame;
static CGRect MapFullFrame;
static CGPoint MapCenter;

@interface PDLocationsMapViewController ()

@property (nonatomic, strong) NSArray *locations;

- (void)showAnnotationsOnMapWithLocations:(NSArray *)aLocations;
- (MKCoordinateRegion)regionThatFitsAllLocations:(NSArray *)locations;

- (IBAction)tappedOnMapView;
@end

@implementation PDLocationsMapViewController

@synthesize delegate = _delegate, dataSource = _dataSource;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
         self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}

- (id)initWithDelegate:(id)adelegate andDataSource:(id)adataSource {
    self = [super initWithNibName:@"PDLocationsMapViewController" bundle:nil];
    if (self) {
        // Custom initialization
        _delegate = adelegate;
        _dataSource = adataSource;
		
		if([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
			self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    MapCenter = self.mapView.center;
    MapOriginalFrame = self.mapView.frame;
	
    CGSize size = [UIScreen mainScreen].bounds.size;
    MapFullFrame = CGRectMake(0, 0, size.width, size.height);
	
    [self.tapGesture addTarget:self action:@selector(tappedOnMapView)];
    [self.mapView addGestureRecognizer:self.tapGesture];
    
    //DataSource
    if ([self.dataSource respondsToSelector:@selector(locationsForShowingInLocationsMap)]) {
        _locations = [self.dataSource locationsForShowingInLocationsMap];

        [self showAnnotationsOnMapWithLocations:self.locations];
    } else {
        NSLog(@"PDLocationsMapViewDataSource not set");
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Helpers

- (void)showAnnotationsOnMapWithLocations:(NSArray *)aLocations {
    for (PDLocation *location in aLocations) {
        MapPoint *mapPoint = [[MapPoint alloc] initWithCoordinate:location.location
															title:location.name
														 subTitle:location.desc];
        [self.mapView addAnnotation:mapPoint];
    }
	
	if(aLocations.count == 1) {
		[self.mapView selectAnnotation:self.mapView.annotations[0]
							  animated:YES];
	}
    
    MKCoordinateRegion region = [self regionThatFitsAllLocations:self.locations];
    [self.mapView setRegion:region];
}

- (MKCoordinateRegion)regionThatFitsAllLocations:(NSArray *)locations {
	if (locations.count == 1) {
		MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(((PDLocation*)locations[0]).location, 50000, 50000);
		MKCoordinateRegion adjustedRegion = [self.mapView regionThatFits:viewRegion];
		return adjustedRegion;
	}
	
    float Lat_Min = FLT_MAX, Lat_Max = -FLT_MAX;
    float Long_Max = -FLT_MAX, Long_Min = FLT_MAX;
    
    for (PDLocation *p in self.locations) {
		if(p.location.latitude < Lat_Min) {
			Lat_Min = p.location.latitude;
		}
		
		if(p.location.latitude > Lat_Max) {
			Lat_Max = p.location.latitude;
		}
		
		if(p.location.longitude < Long_Min) {
			Long_Min = p.location.longitude;
		}
		
		if(p.location.longitude > Long_Max) {
			Long_Max = p.location.longitude;
		}
		
    }
    
    CLLocationCoordinate2D min = CLLocationCoordinate2DMake(Lat_Min, Long_Min);
    
    CLLocationCoordinate2D max = CLLocationCoordinate2DMake(Lat_Max, Long_Max);
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((max.latitude + min.latitude) / 2.0, (max.longitude + min.longitude) / 2.0);
	
	CLLocationDegrees width = max.latitude - min.latitude;
	CLLocationDegrees height = max.longitude - min.longitude;
    MKCoordinateSpan span = MKCoordinateSpanMake(width * 1.20, height * 1.20);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    
    return region;
}

- (IBAction)tappedOnMapView {
    [self.view bringSubviewToFront:self.mapView];
    
    if (CGRectEqualToRect(self.mapView.bounds, MapOriginalFrame)) {
        [UIView animateWithDuration:0.30 animations:^{
            self.mapView.frame = MapFullFrame;
        } completion:^(BOOL finished) {
            [self.mapView removeGestureRecognizer:self.tapGesture];
            NSLog(@"After done %@", [NSValue valueWithCGRect:self.mapView.bounds]);
        }];
    } else {
        [UIView animateWithDuration:0.30 animations:^{
            self.mapView.frame = MapOriginalFrame;
        } completion:^(BOOL finished) {
            [self.mapView addGestureRecognizer:self.tapGesture];
            NSLog(@"After done %@", [NSValue valueWithCGRect:self.mapView.bounds]);
        }];
    }
}

#pragma mark -
#pragma mark MapView

#pragma mark - TableView Methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

- (void)viewDidUnload {
    [self setTapGesture:nil];
    [super viewDidUnload];
}
@end
