//
//  ReminderViewController.h
//  ScaryBugs
//
//  Created by Yue Xing on 11/4/15.
//
//

#ifndef ReminderViewController_h
#define ReminderViewController_h

@protocol ReminderViewControllerDelegate <NSObject>

- (void)setReminderDate:(NSDate*)date repeatInterval:(NSCalendarUnit)repeatInterval;

@end

@interface ReminderViewController: UIViewController

- (id)initWithDelegate:(id<ReminderViewControllerDelegate>)d withText:(NSString*)text;

@end

#endif /* ReminderViewController_h */
