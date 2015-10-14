//
//  RWTScaryBugDoc.m
//  ScaryBugs
//
//  Created by Jorge Jordán Arenas on 04/02/14.
//
//

#import "RWTScaryBugDoc.h"
#import "RWTAppDelegate.h"

@interface UIImage (PhoenixMaster)
- (UIImage *) makeThumbnailOfSize:(CGSize)size;
@end

@implementation UIImage (PhoenixMaster)
- (UIImage *) makeThumbnailOfSize:(CGSize)size
{
  UIGraphicsBeginImageContextWithOptions(size, NO, UIScreen.mainScreen.scale);
  // draw scaled image into thumbnail context
  [self drawInRect:CGRectMake(0, 0, size.width, size.height)];
  UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();
  // pop the context
  UIGraphicsEndImageContext();
  if(newThumbnail == nil) {
    NSLog(@"could not scale image");
  }
  return newThumbnail;
}
@end

@implementation RWTScaryBugDoc

@synthesize thumbImage = _thumbImage, fullImage = _fullImage;

- (id)initWithTitle:(NSString*)title rating:(int)rating imagePath:(NSString*)imagePath;
{
  if ((self = [super init])) {
    self.title = title;
    self.rating = rating;
    [self setImagePath:imagePath];
  }
  return self;
}

- (void)setImagePath:(NSString *)imagePath
{
  _imagePath = imagePath;
  _thumbImage = _fullImage = nil;
  
  if(imagePath != nil) {
    _fullImage = [UIImage imageNamed:[RWTAppDelegate getFullPath:  _imagePath]];
    _thumbImage = [_fullImage makeThumbnailOfSize:CGSizeMake(70,70)];
  }
}

-(UIImage *) thumbImage
{
  return _thumbImage;
}

-(UIImage *) fullImage
{
  return _fullImage;
}

- (NSComparisonResult)compare:(RWTScaryBugDoc *)otherObject {
  if(self.rating < otherObject.rating) {
    return NSOrderedDescending;
  } else if (self.rating == otherObject.rating) {
    return NSOrderedSame;
  } else {
    return NSOrderedAscending;
  }
}


@end
