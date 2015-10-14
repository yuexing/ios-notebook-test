//
//  LocationPickerController.h
//
//  Created by Yue Xing on 10/13/15.
//
//

#ifndef LocationPickerController_h
#define LocationPickerController_h

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol LocationPickerControllerDelegate <NSObject>

- (void)selectLocationCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)selectLocation:(NSString *)location coordinate:(CLLocationCoordinate2D)coordinate;

@end

@interface LocationPickerController : UIViewController

- (id)initWithDelegate:(id<LocationPickerControllerDelegate>)d searchText: (NSString*) searchText;

@end
#endif /* LocationPickerController_h */
