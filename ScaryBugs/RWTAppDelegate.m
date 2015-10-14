//
//  RWTAppDelegate.m
//  ScaryBugs
//
//  Created by Jorge Jordán Arenas on 04/02/14.
//
//

#import "RWTAppDelegate.h"
#import "RWTMasterViewController.h"
#import "RWTScaryBugDoc.h"
#include <stdlib.h>

#import <CoreData/NSEntityDescription.h>
#import <CoreData/NSManagedObject.h>
#import <CoreData/NSManagedObjectContext.h>
#import <CoreData/NSFetchRequest.h>
#import <CoreData/NSPersistentStoreCoordinator.h>
#import <CoreData/NSManagedObjectModel.h>

@interface RWTAppDelegate ()

@property NSMutableArray* m_bugs;

@end


@implementation RWTAppDelegate

+ (NSString*) appDirectory
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  return documentsDirectory;
}

+ (NSString*) getFullPath: (NSString*) path
{
  if([[self inapp_images] objectForKey: path] != nil) {
    return path;
  } else {
    return [[RWTAppDelegate appDirectory] stringByAppendingPathComponent: path];
  }
}

+ (NSDictionary*) inapp_images
{
  return @{@"yoga.jpg" : @"Yoga", @"book.jpg" : @"Reading", @"teddy.jpg" : @"Doggy", @"music.jpg": @"Music"};
}

+ (RWTAppDelegate*) shared_instance
{
  return (RWTAppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.m_bugs = [[NSMutableArray alloc] init];
  
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  if([defaults objectForKey:@"yue_notebook"]) {
    for(int i =0; ; ++i) {
      NSDictionary* dict =  [defaults dictionaryForKey:[NSString stringWithFormat:@"yue_notebook%d", i]] ;
      if(!dict) {
        break;
      } else {
        NSString* title = [dict objectForKey: @"title" ],
        *imagePath = [dict objectForKey: @"imagePath" ],
        *location = [dict objectForKey: @"location" ];
        NSLog(@"%@ %@", title, imagePath);
        [self.m_bugs addObject:[ [RWTScaryBugDoc alloc] initWithTitle: title
                                                               rating: 0
                                                            imagePath: imagePath
                                                             location: location]];
      }
    }
  } else {
    NSDictionary* dict = [RWTAppDelegate inapp_images];
    for(NSString* key in dict)
    {
      [self.m_bugs addObject:[ [RWTScaryBugDoc alloc] initWithTitle: [dict objectForKey:key]
                                                             rating: 0
                                                          imagePath: key
                                                           location: nil]];
    }
  }
  
  UINavigationController *navController = (UINavigationController *) self.window.rootViewController;
  RWTMasterViewController *masterController = [navController.viewControllers objectAtIndex:0];
  masterController.bugs = self.m_bugs;
  
  return YES;
}

// persistent the docs
- (void)applicationWillResignActive:(UIApplication *)application
{
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  
  for(int i = 0; i < [self.m_bugs count]; ++i) {
    RWTScaryBugDoc *bug = self.m_bugs[i];
    
    NSLog(@"%@ %@", bug.title, bug.imagePath);
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];;
    if(bug.title) {
      [dict setObject:bug.title forKey:@"title"];
    }
    if(bug.imagePath) {
      [dict setObject:bug.imagePath forKey:@"imagePath"];
    }
    if(bug.location) {
      [dict setObject:bug.location forKey:@"location"];
    }
    [defaults setObject: dict
                 forKey: [NSString stringWithFormat: @"yue_notebook%d", i]];
  }
  
  for(int i = [self.m_bugs count]; ; ++i) {
    NSString* key = [NSString stringWithFormat:@"yue_notebook%d", i];
    if(![defaults dictionaryForKey:key]) {
      break;
    } else {
      [defaults removeObjectForKey:key];
    }
  }
  
  [defaults setObject:@"" forKey:@"yue_notebook"];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
@end
