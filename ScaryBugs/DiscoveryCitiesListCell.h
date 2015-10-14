//
//  DiscoveryCitiesListCell.h
//  tango
//  Copyright (c) 2014 Tango.me. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"

@interface DiscoveryCitiesListCell : UITableViewCell {

}

@property (nonatomic, strong) Location * location;

- (void) updateWithLocation:(Location *) newLocation;

@end
