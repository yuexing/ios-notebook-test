//
//  Location.h
//  Created by Yue Xing on 10/14/15.
//
//

#ifndef Location_h
#define Location_h

@interface Location : NSObject
@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * region;
@property (nonatomic) double latitude;
@property (nonatomic) double longitude;

@end

#endif /* Location_h */
