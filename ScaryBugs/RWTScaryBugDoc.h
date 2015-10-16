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

@property (strong, nonatomic) NSString *imagePath;

@property (strong) NSString *location; // allow the user to add a location

@property (strong, nonatomic) NSString *audioPath;

- (id)initWithTitle:(NSString*)title rating:(int)rating imagePath:(NSString*)imagePath audioPath:(NSString*)audioPath location:(NSString*)location;

- (NSComparisonResult)compare:(RWTScaryBugDoc *)otherObject;

@end