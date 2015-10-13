//
//  RWTDetailViewController.m
//  ScaryBugs
//
//  Created by Jorge Jordán Arenas on 04/02/14.
//
//

#import "RWTDetailViewController.h"
#import "RWTScaryBugDoc.h"
#import "RWTUIImageExtras.h"
#import "SVProgressHUD.h"

#import "RWTAppDelegate.h"

@interface RWTDetailViewController ()
- (void)configureView;

@property (strong, nonatomic) UIActionSheet *attachmentMenuSheet;
@end

@implementation RWTDetailViewController

@synthesize picker = _picker;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
  if (_detailItem != newDetailItem) {
    _detailItem = newDetailItem;
    
    // Update the view.
    [self configureView];
  }
}

- (void)configureView
{
  // Update the user interface for the detail item.
  self.rateView.notSelectedImage = [UIImage imageNamed:@"shockedface2_empty.png"];
  self.rateView.halfSelectedImage = [UIImage imageNamed:@"shockedface2_half.png"];
  self.rateView.fullSelectedImage = [UIImage imageNamed:@"shockedface2_full.png"];
  self.rateView.editable = YES;
  self.rateView.maxRating = 5;
  self.rateView.delegate = self;
  
  if (self.detailItem) {
    self.titleField.text = self.detailItem.title;
    self.rateView.rating = self.detailItem.rating;
    self.imageView.image = [self.detailItem fullImage];
  }
}

- (BOOL)shouldAutorotateToInterfaceOrientation {
  return YES;
}

- (IBAction)titleFieldTextChanged:(id)sender {
  self.detailItem.title = self.titleField.text;
}

#pragma mark UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

#pragma mark RWTRateViewDelegate

- (void)rateView:(RWTRateView *)rateView ratingDidChange:(float)rating {
  self.detailItem.rating = rating;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  [self configureView];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)takePhoto {
  if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
    
    UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                          message:@"Device has no camera"
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles: nil];
    
    [myAlertView show];
    return;
  }
  
  if (self.picker == nil) {
    _picker = [[UIImagePickerController alloc] init];
    _picker.delegate = self;
    _picker.allowsEditing = YES;
  }
  
  _picker.sourceType = UIImagePickerControllerSourceTypeCamera;
  [self presentViewController:_picker animated:YES completion:NULL];
}

- (void)selectPhoto {
  if (self.picker == nil) {
    _picker = [[UIImagePickerController alloc] init];
    _picker.delegate = self;
    _picker.allowsEditing = YES;
  }
  
  _picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
  [self presentViewController:_picker animated:YES completion:NULL];
}

-(void)attachmentActionSheet {
  
  self.attachmentMenuSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                     delegate:self
                                            cancelButtonTitle:@"Cancel"
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:@"Take Photo", @"Pick Photo", nil];
  
  [self.attachmentMenuSheet showInView: self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex: (NSInteger)buttonIndex {
  if (actionSheet == _attachmentMenuSheet) {
    NSLog(@"Button %ld", buttonIndex);
    switch (buttonIndex) {
      case 0:
        [self takePhoto];
        break;
        
      case 1:
        [self selectPhoto];
        break;
      default:
        break;
    }
  }
}

- (IBAction)addPictureTapped:(id)sender {
  [self attachmentActionSheet];
}

#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  
  UIImage *fullImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
  
  // 1) Show status
  [SVProgressHUD showWithStatus:@"Resizing image..."];
  
  // 2) Get a concurrent queue form the system
  dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  
  // 3) save/resize image in background
  dispatch_async(concurrentQueue, ^{
    NSData *imageData = UIImagePNGRepresentation(fullImage);
    
    NSString *timestamp = [NSString stringWithFormat:@"%d", (int)[[NSDate date] timeIntervalSince1970]];
    NSString *imagePath = [NSString stringWithFormat:@"%@.png", timestamp];
    NSString *pathToWrite = [RWTAppDelegate getFullPath: imagePath];
    
    if (![imageData writeToFile: pathToWrite atomically:NO]) {
      NSLog((@"Failed to cache image data to disk"));
    } else {
      NSLog(@"wrote to: %@", pathToWrite);
    }
    
    // 4) Present image in main thread
    dispatch_async(dispatch_get_main_queue(), ^{
      [self.detailItem setImagePath:imagePath];
      self.imageView.image = [self.detailItem fullImage];
      [SVProgressHUD dismiss];
    });
    
  });
  
  [self dismissViewControllerAnimated:YES completion:nil];
  
}

@end
