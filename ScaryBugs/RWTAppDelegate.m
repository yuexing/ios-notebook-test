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

@implementation RWTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  RWTScaryBugDoc *bug1 = [[RWTScaryBugDoc alloc] initWithTitle:@"Yoga" rating:4 thumbImage:[UIImage imageNamed:@"yoga.jpg"] fullImage:[UIImage imageNamed:@"yoga.jpg"]];
  RWTScaryBugDoc *bug2 = [[RWTScaryBugDoc alloc] initWithTitle:@"Reading" rating:3 thumbImage:[UIImage imageNamed:@"book.jpg"] fullImage:[UIImage imageNamed:@"book.jpg"]];
  RWTScaryBugDoc *bug3 = [[RWTScaryBugDoc alloc] initWithTitle:@"Doggy" rating:5 thumbImage:[UIImage imageNamed:@"teddy.jpg"] fullImage:[UIImage imageNamed:@"teddy.jpg"]];
  RWTScaryBugDoc *bug4 = [[RWTScaryBugDoc alloc] initWithTitle:@"Music" rating:1 thumbImage:[UIImage imageNamed:@"music.jpg"] fullImage:[UIImage imageNamed:@"music.jpg"]];
  NSMutableArray *bugs = [NSMutableArray arrayWithObjects:bug1, bug2, bug3, bug4, nil];
  
  UINavigationController *navController = (UINavigationController *) self.window.rootViewController;
  RWTMasterViewController *masterController = [navController.viewControllers objectAtIndex:0];
  masterController.bugs = bugs;
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
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
