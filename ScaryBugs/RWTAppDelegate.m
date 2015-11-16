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

#import <PushKit/PushKit.h>

@interface OpenURLDelegate : NSObject <UIAlertViewDelegate>

- (id) initWithUrl: (NSString*)url;

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@property (strong) NSString *url;

@end

@implementation OpenURLDelegate

- (id) initWithUrl: (NSString*)url
{
  if((self = [super init])) {
    self.url = url;
  }
  return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
  UIApplication * app = [UIApplication sharedApplication];
  
  NSURL * url = [NSURL URLWithString: self.url];
  if ([app canOpenURL: url]) {
    [app openURL: url];
  } else {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[NSString stringWithFormat: @"Can't open the url %@", self.url]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
  }
}
@end

@interface RWTAppDelegate() <PKPushRegistryDelegate>

@property id alertViewdelegate;

@end

@implementation RWTAppDelegate

+ (NSString*) appDirectory
{
  NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirectory = [paths objectAtIndex:0];
  return documentsDirectory;
}

+ (NSURL*) getFullPath: (NSString*)path
{
  NSArray *pathComponents = [NSArray arrayWithObjects:
                             [RWTAppDelegate appDirectory],
                             path,
                             nil];
  return [NSURL fileURLWithPathComponents:pathComponents];
}

+ (NSString*) getFullPathForImage: (NSString*) path
{
  if([[self inapp_images] objectForKey: path] != nil) {
    return path;
  } else {
    return [[RWTAppDelegate appDirectory] stringByAppendingPathComponent: path];
  }
}

+ (NSDictionary*) parsedDictionaryWithDeeplinkQuery:(NSString*)query
{
  NSArray *varList = [query componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"=&"]];
  NSMutableDictionary *theQueryDict = [[NSMutableDictionary alloc] init];
  for (int i=0; i+1 < [varList count]; i+=2)  {
    theQueryDict[(NSString*)varList[i]] = (NSString*)varList[i+1];
  }
  return theQueryDict;
}

-(BOOL)application:(UIApplication *)application
           openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation
{
  NSLog(@"%@ %@ %@", [url scheme], [url host], [url query]);
  NSDictionary *dict = [RWTAppDelegate parsedDictionaryWithDeeplinkQuery: [url query]];
  if([[url host] isEqualToString:@"notify"]) {
    NSString* title = [dict objectForKey:@"title"]? : @"Info";
    NSString* message = [dict objectForKey:@"message"]? : @"Message";
    message = [message stringByReplacingOccurrencesOfString:@"%20" withString:@" "];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    return YES;
  } else if ([[url host] isEqualToString:@"can_open_url"]) {
    NSString* url = @"tangodev://q?logable";// [dict objectForKey:@"url"];
    self.alertViewdelegate = [[OpenURLDelegate alloc] initWithUrl:url];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"can open url"
                                                    message:url
                                                   delegate:self.alertViewdelegate
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
    return YES;
  }
  return NO;
}

+ (NSDictionary*) inapp_images
{
  return @{@"yoga.jpg" : @"Yoga", @"book.jpg" : @"Reading", @"teddy.jpg" : @"Doggy", @"music.jpg": @"Music"};
}

+ (void)removeFile:(NSString *)fileName
{
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSString *filePath = [[RWTAppDelegate appDirectory] stringByAppendingPathComponent:fileName];
  NSError *error;
  if(![fileManager removeItemAtPath:filePath error:&error]) {
    NSLog(@"Could not delete file %@:%@ ", filePath, [error localizedDescription]);
  }
}

+ (RWTAppDelegate*) shared_instance
{
  return (RWTAppDelegate*)[[UIApplication sharedApplication] delegate];
}

- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
  NSLog(@"%s: notificationSettings: %@", __FUNCTION__, notificationSettings.description);
  
  [application registerForRemoteNotifications];
}

// This method is used to receive the data which we get using post method.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data
{
  NSLog(@"%s: %@", __FUNCTION__, [data description]);
}

// This method receives the error report in case of connection is not made to server.
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
  NSLog(@"%s: %@", __FUNCTION__, [error localizedDescription]);
}

// This method is used to process the data after connection has made successfully.
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  
}


- (void)sendDeviceToken: (nonnull NSString*) deviceToken withType: (NSString*) type
{
  NSString *post = [NSString stringWithFormat:@"token=%@&type=%@",deviceToken, type];
  NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
  NSString *postLength = [NSString stringWithFormat:@"%lu",(unsigned long)[postData length]];

  NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init] ;
  [request setURL:[NSURL URLWithString:@"http://localhost/upload-token.php"]];
  [request setHTTPMethod:@"POST"];
  [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
  [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
  [request setHTTPBody:postData];
  NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
  
  if(conn) {
    NSLog(@"Connection Successful");
  } else {
    NSLog(@"Connection could not be made");
  }
}

- (void)receivedToken: (nonnull NSData*) deviceToken withType: (NSString*) type
{
  NSString *token = [[deviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
  token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
  NSLog(@"%@: %@", type, token);
  
  [self sendDeviceToken:token withType:type];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken
{
  NSLog(@"%s", __FUNCTION__);
  [self receivedToken:deviceToken withType:@"remote notification token"];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
  NSLog(@"%s: Error: %@", __FUNCTION__, [error localizedDescription]);
}

// begin: to handle the custom actions available in iOS 8
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier
forLocalNotification:(UILocalNotification *)notification
  completionHandler:(void (^)())completionHandler
{
  NSLog(@"%s %@", __FUNCTION__, identifier);
  completionHandler();
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier
forRemoteNotification:(NSDictionary *)userInfo
  completionHandler:(void (^)())completionHandler
{
  NSLog(@"%s %@ %@", __FUNCTION__, identifier, [userInfo description]);
  completionHandler();
}
// end


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
  NSLog(@"%s %@", __FUNCTION__, [userInfo description]);
}

// app is launched in the background or resumed: silent push
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
  NSLog(@"%s %@", __FUNCTION__, [userInfo description]);
  completionHandler(UIBackgroundFetchResultNewData);
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
  NSLog(@"%s %@", __FUNCTION__, [notification alertTitle]);
  
  UIApplicationState state = [application applicationState];
  if (state == UIApplicationStateActive) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Reminder"
                                                    message:notification.alertTitle
                                                   delegate:self cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil];
    [alert show];
  }
}

- (void)pushRegistry:(PKPushRegistry *)registry didUpdatePushCredentials: (PKPushCredentials *)credentials forType:(NSString *)type {
  [self receivedToken:credentials.token withType:@"voip notification token"];
}

- (void)pushRegistry:(PKPushRegistry *)registry didReceiveIncomingPushWithPayload:(PKPushPayload *)payload forType:(NSString *)type {
  NSLog(@"%s %@", __FUNCTION__, [payload.dictionaryPayload description]);
}

- (void) registerVOIP {
  // Create a push registry object
  PKPushRegistry * voipRegistry = [[PKPushRegistry alloc] initWithQueue: dispatch_get_main_queue()];
  // Set the registry's delegate to self
  voipRegistry.delegate = self;
  // Set the push type to VoIP
  voipRegistry.desiredPushTypes = [NSSet setWithObject:PKPushTypeVoIP]; // register
}

- (void) registerNotification {
  UIMutableUserNotificationAction *action1;
  action1 = [[UIMutableUserNotificationAction alloc] init];
  [action1 setActivationMode:UIUserNotificationActivationModeBackground];
  [action1 setTitle:@"Action 1"];
  [action1 setIdentifier:@"action_one_ident"];
  [action1 setDestructive:NO];
  [action1 setAuthenticationRequired:NO];
  
  UIMutableUserNotificationAction *action2;
  action2 = [[UIMutableUserNotificationAction alloc] init];
  [action2 setActivationMode:UIUserNotificationActivationModeBackground];
  [action2 setTitle:@"Action 2"];
  [action2 setIdentifier:@"action_two_ident"];
  [action2 setDestructive:NO];
  [action2 setAuthenticationRequired:NO];
  
  UIMutableUserNotificationCategory *actionCategory;
  actionCategory = [[UIMutableUserNotificationCategory alloc] init];
  [actionCategory setIdentifier:@"actionable_ident"];
  [actionCategory setActions:@[action1, action2]
                  forContext:UIUserNotificationActionContextDefault];
  
  NSSet *categories = [NSSet setWithObject:actionCategory];
  
  UIUserNotificationType types = (UIUserNotificationTypeAlert|
                                  UIUserNotificationTypeSound|
                                  UIUserNotificationTypeBadge);
  
  UIUserNotificationSettings *settings;
  settings = [UIUserNotificationSettings settingsForTypes:types
                                               categories:categories];
  
  [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSLog(@"%s", __FUNCTION__);
  
  // ios8 voip
  [self registerVOIP];
  
  // pre-ios8
  //[self registerNotification];
  
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
        *audioPath = [dict objectForKey:@"audioPath"],
        *location = [dict objectForKey: @"location" ];
        NSString* reminder = [[dict objectForKey: @"reminder"] objectForKey:@"date"];
        [self.m_bugs addObject:[ [RWTScaryBugDoc alloc] initWithTitle: title
                                                               rating: 0
                                                            imagePath: imagePath
                                                            audioPath: audioPath
                                                             location: location]];
        if(reminder) {
          [[self.m_bugs lastObject] setReminder:[[ReminderData alloc] initWithDate: reminder]];
        }
        NSLog(@"load: %@ %@ %@ %@ %@", title, imagePath, audioPath, location, reminder);
      }
    }
  } else {
    NSDictionary* dict = [RWTAppDelegate inapp_images];
    for(NSString* key in dict)
    {
      [self.m_bugs addObject:[ [RWTScaryBugDoc alloc] initWithTitle: [dict objectForKey:key]
                                                             rating: 0
                                                          imagePath: key
                                                          audioPath:nil
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
    
    NSLog(@"write: %@ %@ %@ %@ %@", bug.title, bug.imagePath, bug.audioPath, bug.location, bug.reminder.date);
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if(bug.title) {
      [dict setObject:bug.title forKey:@"title"];
    }
    if(bug.imagePath) {
      [dict setObject:bug.imagePath forKey:@"imagePath"];
    }
    if(bug.audioPath) {
      [dict setObject:bug.audioPath forKey:@"audioPath"];
    }
    if(bug.location) {
      [dict setObject:bug.location forKey:@"location"];
    }
    if(bug.reminder) {
      NSMutableDictionary *reminder = [[NSMutableDictionary alloc] init];
      [reminder setObject:bug.reminder.date forKey:@"date"];
      [dict setObject:reminder forKey:@"reminder"];
    }
    
    [defaults setObject: dict
                 forKey: [NSString stringWithFormat: @"yue_notebook%d", i]];
  }
  
  for(int i = (int)[self.m_bugs count]; ; ++i) {
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
  NSLog(@"%s", __FUNCTION__);
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  NSLog(@"%s", __FUNCTION__);
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  NSLog(@"%s", __FUNCTION__);
  
  // reset badge
  application.applicationIconBadgeNumber = 0;
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  NSLog(@"%s", __FUNCTION__);
}
@end
