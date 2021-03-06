//
//  RWTScaryBugDoc.m
//  ScaryBugs
//
//  Created by Jorge Jordán Arenas on 04/02/14.
//
//

#import "RWTScaryBugDoc.h"
#import "RWTAppDelegate.h"
#import "RWTUIImageExtras.h"

@implementation ReminderData

-(id) initWithDate: (NSString*)date
{
  if(self = [super init]) {
    self.date = date;
  }
  return self;
}

@end

@implementation RWTScaryBugDoc

@synthesize thumbImage = _thumbImage, fullImage = _fullImage;

- (id)initWithTitle:(NSString*)title rating:(int)rating imagePath:(NSString*)imagePath  audioPath:(NSString*)audioPath location:(NSString*)location
{
  if ((self = [super init])) {
    self.title = title;
    self.rating = rating;
    self.location = location;
    [self setAudioPath:audioPath];
    [self setImagePath:imagePath];
  }
  return self;
}

- (void)setAudioPath:(NSString *)audioPath
{
  if(_audioPath) {
    [RWTAppDelegate removeFile:_audioPath];
  }
  
  _audioPath = audioPath;
}

- (void)setImagePath:(NSString *)imagePath
{
  if(_imagePath) {
    [RWTAppDelegate removeFile:_imagePath];
  }
  
  _imagePath = imagePath;
  _thumbImage = _fullImage = nil;
  
  if(imagePath != nil) {
    _fullImage = [UIImage imageNamed:[RWTAppDelegate getFullPathForImage:  _imagePath]];
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
