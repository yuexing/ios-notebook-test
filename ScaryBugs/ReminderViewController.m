//
//  ReminderViewController.m
//  ScaryBugs
//
//  Created by Yue Xing on 11/4/15.
//
//

#import <Foundation/Foundation.h>
#import "ReminderViewController.h"


@implementation ReminderViewController
{
  UIDatePicker *datePicker_;
  id<ReminderViewControllerDelegate> delegate_;
  NSString* text_;
}

- (id)initWithDelegate:(id<ReminderViewControllerDelegate>)d withText:(NSString*) text
{
  if(self = [super init]) {
    delegate_ = d;
    text_ = text;
    self.title = @"Set Reminder";
  }
  
  return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.view.backgroundColor = [UIColor whiteColor];
  
  datePicker_ = [[UIDatePicker alloc] initWithFrame: self.view.bounds];
  datePicker_.backgroundColor = [UIColor clearColor];
  datePicker_.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin);
  // TODO: set limit
  [self.view addSubview:datePicker_];
  
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(done:)];
  self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)done:(id)sender
{
  NSDate *pickerDate = [datePicker_ date];

  // Schedule the notification
  UILocalNotification* localNotification = [[UILocalNotification alloc] init];
  localNotification.fireDate = pickerDate;
  localNotification.alertTitle = text_;
  localNotification.alertAction = @"Show me the item";
  localNotification.timeZone = [NSTimeZone localTimeZone];
  localNotification.applicationIconBadgeNumber = [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
  [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
  
  [delegate_ setReminderDate:localNotification.fireDate repeatInterval:0];
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    [self.navigationController popViewControllerAnimated:YES];
  });
}

@end