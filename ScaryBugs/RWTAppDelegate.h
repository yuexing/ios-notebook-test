//
//  RWTAppDelegate.h
//  ScaryBugs
//
//  Created by Jorge Jordán Arenas on 04/02/14.
//
//

#import <UIKit/UIKit.h>

@interface RWTAppDelegate : UIResponder <UIApplicationDelegate>

+ (NSString*) appDirectory;

+ (void)removeFile:(NSString *)fileName;

+ (NSString*) getFullPath: (NSString*) path;

+ (NSURL*) getUrl: (NSString*)path;

+ (RWTAppDelegate*) shared_instance;

@property (strong, nonatomic) UIWindow *window;

@end
