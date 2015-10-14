//
//  LocationPickerController.m
//
//  Created by Yue Xing on 10/13/15.
//
//

#import <Foundation/Foundation.h>
#import <AddressBookUI/AddressBookUI.h>
#import "LocationPickerController.h"
#import "Location.h"
#import "DiscoveryCitiesListCell.h"

@interface LocationPickerController () <MKMapViewDelegate, UISearchDisplayDelegate, UITableViewDataSource, UITableViewDelegate, CLLocationManagerDelegate>

@property (weak) id<LocationPickerControllerDelegate> delegate;
@property (strong) MKMapView *mapView;
@property (strong) MKPointAnnotation *selectedAnnotation;
@property (strong) UISearchBar *searchBar;
@property (strong) UISearchDisplayController *theSearchDisplayController;
@property (strong) CLLocationManager *locationManager;
@property (strong) NSMutableArray* filteredCities;

@property (assign) CLLocationCoordinate2D lastSearchCoordinate;
@property (strong) NSString* lastSearchText;
@end

@implementation UIView (Extension)

- (void)removeAllGestureRecognizers {
  for (UIGestureRecognizer *r in self.gestureRecognizers) {
    [self removeGestureRecognizer:r];
  }
}

- (void)addSingleTapGestureWithTarget:(id)target action:(SEL)action {
  UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:target action:action];
  [self addGestureRecognizer:singleTapGesture];
}
@end

@implementation Location
@end

@implementation LocationPickerController

- (id)initWithDelegate:(id<LocationPickerControllerDelegate>)d searchText: (NSString*) searchText
{
  self = [super initWithNibName:nil bundle:nil];
  if (self) {
    self.delegate = d;
    self.title = @"Set Location";
    self.lastSearchCoordinate = kCLLocationCoordinate2DInvalid;
    
    if(searchText) {
      self.lastSearchText = searchText;
      
      NSArray *strings = [searchText componentsSeparatedByString:@", "];
      int startIdx = 0;
      if( [strings count] == 3 ) {
        startIdx = 1;
      }
      
      _lastSearchCoordinate.latitude = [strings[startIdx] doubleValue];
      _lastSearchCoordinate.longitude = [strings[startIdx + 1] doubleValue];
    }
  }
  return self;
}


- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.searchBar = [[UISearchBar alloc] init];
  [self.view addSubview: self.searchBar];
  self.searchBar.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bar(44)]" options:kNilOptions metrics:nil views:@{@"bar":self.searchBar}]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[bar]|" options:kNilOptions metrics:nil views:@{@"bar":self.searchBar}]];
  [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.searchBar attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.topLayoutGuide attribute:NSLayoutAttributeBottom multiplier:1 constant:0]];
  
  self.mapView = [[MKMapView alloc] initWithFrame:self.view.bounds];
  self.mapView.delegate = self;
  [self.mapView addSingleTapGestureWithTarget:self action:@selector(userTapOnMap:)];
  self.mapView.translatesAutoresizingMaskIntoConstraints = NO;
  [self.view addSubview:self.mapView];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[bar]-0-[map]|" options:kNilOptions metrics:nil views:@{@"map":self.mapView, @"bar":self.searchBar}]];
  [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[map]|" options:kNilOptions metrics:nil views:@{@"map":self.mapView}]];
 
  /*UIButton *goToCurrentLocBtn = [[UIButton alloc] initWithFrame:CGRectZero];
  goToCurrentLocBtn.backgroundColor = [UIColor clearColor];
  [goToCurrentLocBtn setImage: [UIImage imageNamed:@"btn_current_location_normal.png"] forState:UIControlStateNormal];
  [goToCurrentLocBtn setImage: [UIImage imageNamed:@"btn_current_location_pressed.png"] forState:UIControlStateHighlighted];
  [goToCurrentLocBtn addTarget:self action:@selector(goToCurrentLocBtnClicked) forControlEvents:UIControlEventTouchUpInside];
  [self.mapView addSubview:goToCurrentLocBtn];
  goToCurrentLocBtn.translatesAutoresizingMaskIntoConstraints = NO;
  [self.mapView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[goToCurrentLocBtn(40)]-15-|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(goToCurrentLocBtn)]];
  [self.mapView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[goToCurrentLocBtn(40)]-15-|" options:kNilOptions metrics:nil views:NSDictionaryOfVariableBindings(goToCurrentLocBtn)]]; */
  
  self.theSearchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
  self.theSearchDisplayController.delegate = self;
  self.theSearchDisplayController.searchResultsDataSource = self;
  self.theSearchDisplayController.searchResultsDelegate = self;
  
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  self.locationManager.distanceFilter = 50.0f;
  self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
  
  [self requestLocationAuthorization];
}

- (void)requestLocationAuthorization
{
  CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
  
  // If the status is denied , display an alert
  if (status == kCLAuthorizationStatusDenied) {
    NSString *title;
    title = @"Location services are off";
    NSString *message = @"To use location you must turn on 'While Using' in the Location Services Settings";
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Settings", nil];
    [alertView show];
  }
  // The user has not enabled any location services. Request background authorization.
  else if (status == kCLAuthorizationStatusNotDetermined) {
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
      [self.locationManager requestWhenInUseAuthorization];
    }
  }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  if (buttonIndex == 1) {
    // Send the user to the Settings for this app
    NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [[UIApplication sharedApplication] openURL:settingsURL];
  }
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  self.searchBar.text = nil;
  self.mapView.showsUserLocation = YES;
  
  if (CLLocationCoordinate2DIsValid(self.lastSearchCoordinate)) {
    if (self.lastSearchText) {
      self.searchBar.text = self.lastSearchText;
    }
    [self animateToCoordinate:self.lastSearchCoordinate];
    [self addAnnotationByCoordinate:self.lastSearchCoordinate];
  } else {
    [self.locationManager startUpdatingLocation];
  }
}

- (void)animateToLocation:(CLLocation *)location {
  CLLocationCoordinate2D coordinate;
  coordinate.latitude = location.coordinate.latitude;
  coordinate.longitude = location.coordinate.longitude;
  [self animateToCoordinate:coordinate];
}

- (void)animateToCoordinate:(CLLocationCoordinate2D)coordinate {
  MKCoordinateRegion region;
  MKCoordinateSpan span;
  span.latitudeDelta = 4;
  span.longitudeDelta = 4;
  region.span = span;
  region.center = coordinate;
  [self.mapView setRegion:region animated:YES];
}

- (void)userTapOnMap:(UITapGestureRecognizer *)gestureRecognizer {
  if (gestureRecognizer.state != UIGestureRecognizerStateEnded) {
    return;
  }
  CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
  CLLocationCoordinate2D touchMapCoordinate = [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
  [self userSelectLocationCoordinate:touchMapCoordinate];
}


- (void)userSelectLocationCoordinate:(CLLocationCoordinate2D)coordinate {
  [self userSelectLocation:nil Coordinate:coordinate];
}

- (void)userSelectLocation:(NSString *)locationString Coordinate:(CLLocationCoordinate2D)coordinate {
  [self addAnnotationByCoordinate:coordinate];
  
  if (locationString) {
    [self.delegate selectLocation:locationString coordinate:coordinate];
  } else {
    [self.delegate selectLocationCoordinate:coordinate];
  }
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self.navigationController popViewControllerAnimated:YES];
  });
}


- (void)addAnnotationByCoordinate:(CLLocationCoordinate2D)coordinate {
  if (self.selectedAnnotation) {
    [self.mapView removeAnnotation:self.selectedAnnotation];
  }
  self.selectedAnnotation = [[MKPointAnnotation alloc] init];
  self.selectedAnnotation.coordinate = coordinate;
  [self.mapView addAnnotation:self.selectedAnnotation];
}

- (void) filterContentForSearchText_: (NSString*) searchText
{
  if(searchText == nil ||[searchText isEqualToString: @""]) {
    return ;
  }
  
  MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
  request.naturalLanguageQuery = searchText;

  MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:request];
  NSMutableArray *searchResults = [[NSMutableArray alloc] init];
  
  [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error)
   {
     
     if (error != nil)
     {
       NSString * errorMsg;
       BOOL displayError = NO;
       
       if (error.code == MKErrorUnknown || error.code == MKErrorServerFailure)
       {
         errorMsg = @"Server error. Please try again.";
         displayError = YES;
       }
       
       if (error.code == MKErrorLoadingThrottled)
       {
         errorMsg = @"There are too many search requests. Please try again later.";
         displayError = YES;
       }
       
       if (displayError) {
         [[[UIAlertView alloc] initWithTitle:errorMsg
                                     message:nil
                                    delegate:nil
                           cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
         return;
       }
     }
     
     for (MKMapItem *item in response.mapItems)
     {
       NSString * address = ABCreateStringWithAddressDictionary([item.placemark addressDictionary], YES);
       
       Location * location = [[Location alloc] init];
       location.name = [[address componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] componentsJoinedByString:@" "];
       location.region = item.placemark.country;
       location.latitude = item.placemark.location.coordinate.latitude;
       location.longitude = item.placemark.location.coordinate.longitude;
       [searchResults addObject:location];
     }
     
     self.filteredCities = searchResults;
     [self.theSearchDisplayController.searchResultsTableView reloadData];
   }];
  
  return;
}

- (void) filterContentForSearchText: (NSString*) searchText
{
  [NSObject cancelPreviousPerformRequestsWithTarget: self];
  
  [self performSelector: @selector(filterContentForSearchText_:)
             withObject: searchText
             afterDelay: 0.5];
}

#pragma mark - UISearchDisplayController Delegate Methods
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
  [self filterContentForSearchText: searchString];
  return NO;
}

- (void)searchDisplayControllerDidEndSearch:(UISearchDisplayController *)controller
{
  [NSObject cancelPreviousPerformRequestsWithTarget: self];
  
  [self.filteredCities removeAllObjects];
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.filteredCities.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  NSString * cellId = @"searchCityInMap";
  DiscoveryCitiesListCell *newCell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (!newCell){
    newCell = [[DiscoveryCitiesListCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
  }
  
  [newCell updateWithLocation:self.filteredCities[indexPath.row]];
  
  return newCell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  CLLocationCoordinate2D coordToGo;
  
  DiscoveryCitiesListCell *cell = (DiscoveryCitiesListCell*) [tableView cellForRowAtIndexPath:indexPath];
  Location *selected = cell.location;
  
  if (selected == nil) {
    return;
  }
  
  coordToGo.latitude = selected.latitude;
  coordToGo.longitude = selected.longitude;
  
  [self.theSearchDisplayController.searchBar resignFirstResponder];
  [self.theSearchDisplayController setActive:NO animated:NO];
  NSString * locationText = [selected.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
  self.searchBar.text = locationText;
  [tableView reloadData];
  [self animateToCoordinate:coordToGo];
  
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self userSelectLocation:locationText Coordinate:coordToGo];
  });
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  CLLocation *newLocation = locations[0];
  [self.locationManager stopUpdatingLocation];
  [self animateToLocation:newLocation];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
  if ([annotation isKindOfClass:[MKPinAnnotationView class]]) {
    static NSString *identifier = @"MyLocation";
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *) [_mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (annotationView == nil) {
      annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
      annotationView.enabled = YES;
      annotationView.canShowCallout = YES;
      annotationView.animatesDrop = YES;
    } else {
      annotationView.annotation = annotation;
    }
    return annotationView;
  }
  return nil;
}

@end