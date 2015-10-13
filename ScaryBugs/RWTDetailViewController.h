//
//  RWTDetailViewController.h
//  ScaryBugs
//
//  Created by Jorge Jordán Arenas on 04/02/14.
//
//

#import <UIKit/UIKit.h>
#import "RWTRateView.h"

@class RWTScaryBugDoc;

@interface RWTDetailViewController : UIViewController <UITextFieldDelegate, RWTRateViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) RWTScaryBugDoc *detailItem;
@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet RWTRateView *rateView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (strong, nonatomic) UIImagePickerController *picker;

- (IBAction)addPictureTapped:(id)sender;
- (IBAction)titleFieldTextChanged:(id)sender;

@end
