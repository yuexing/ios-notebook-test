//
//  RWTScaryBugDoc.h
//  ScaryBugs
//
//  Created by Jorge Jordán Arenas on 04/02/14.
//
//

#import <Foundation/Foundation.h>

@class RWTScaryBugData;

@interface RWTScaryBugDoc : NSObject

@property (strong, readonly) UIImage *thumbImage;
@property (strong, readonly) UIImage *fullImage;

@property (strong) NSString *title;
@property (assign) int rating;

@property (strong) NSString *imagePath;

- (id)initWithTitle:(NSString*)title rating:(int)rating imagePath:(NSString*)imagePath;

- (NSComparisonResult)compare:(RWTScaryBugDoc *)otherObject;

@end