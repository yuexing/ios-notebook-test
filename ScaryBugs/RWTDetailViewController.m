//
//  RWTDetailViewController.m
//

#import "RWTDetailViewController.h"
#import "RWTScaryBugDoc.h"
#import "RWTUIImageExtras.h"
#import "SVProgressHUD.h"

#import "RWTAppDelegate.h"
#import "LocationPickerController.h"
#import "ReminderViewController.h"

#import <AVFoundation/AVFoundation.h>


@interface RWTDetailViewController () <LocationPickerControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, ReminderViewControllerDelegate> {
  AVAudioRecorder *recorder;
  AVAudioPlayer *player;
  
  NSString *curAudioPath;
}
- (void)configureView;

@property (strong, nonatomic) UIActionSheet *attachmentMenuSheetForPic;
@property (strong, nonatomic) UIActionSheet *attachmentMenuSheetForMore;

@property (weak, nonatomic) UIButton *locationPicker;

@property (weak, nonatomic) UIButton *recordController;

@property (weak, nonatomic) UIButton *playBtn;

@property (weak, nonatomic) UIButton *addMoreBtn;

@property (weak, nonatomic) UIButton *remindBtn;

@property (weak, nonatomic) RWTScaryBugDoc *detailItem;

@property NSMutableArray* btns;

@end

@implementation RWTDetailViewController {
  NSInteger m_index;
}

@synthesize picker = _picker;

#pragma mark - Managing the detail item

- (BOOL)setItemIndex:(NSInteger)index
{
  if(index >= [[RWTAppDelegate shared_instance].m_bugs count] ||
     index < 0) {
    return NO;
  }
  
  m_index = index;
  
  RWTScaryBugDoc* newDetailItem = [RWTAppDelegate shared_instance].m_bugs[index];
  
  if (_detailItem != newDetailItem) {
    _detailItem = newDetailItem;
  }
  
  return YES;
}

- (UIView*) getLastView
{
  if([self.btns count]) {
    return [self.btns lastObject];
  }
  return self.imageView;
}

- (void)configureView
{
  if (!self.detailItem) {
    return;
  }
  self.titleField.text = self.detailItem.title;
  self.imageView.image = [self.detailItem fullImage];
  
  [self removeAllBtns];
  
  if(self.detailItem.location) {
    [self attchLocationPickerFollowingView: [self getLastView]];
  }
  
  if(self.detailItem.audioPath) {
    [self attachPlayBtnFollowingView:[self getLastView]];
  }
  
  if(self.detailItem.reminder) {
    [self attachRemindFollowingView:[self getLastView]];
  }
  
  [self attachAddMoreFollowingView: [self getLastView]];
}

-(void)attachActionSheetForMore {
  self.attachmentMenuSheetForMore = [[UIActionSheet alloc] initWithTitle:nil
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel"
                                           destructiveButtonTitle:nil
                                                otherButtonTitles:@"Pick Location", @"Record Audio", @"Add Reminder", nil];
  
  [self.attachmentMenuSheetForMore showInView: self.view];
}


-(void)attachmentActionSheetForPic {
  
  self.attachmentMenuSheetForPic = [[UIActionSheet alloc] initWithTitle:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                 destructiveButtonTitle:nil
                                                      otherButtonTitles:@"Take Photo", @"Pick Photo", nil];
  
  [self.attachmentMenuSheetForPic showInView: self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex: (NSInteger)buttonIndex {
  if (actionSheet == _attachmentMenuSheetForPic) {
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
  } else if(actionSheet == _attachmentMenuSheetForMore) {
    switch (buttonIndex) {
      case 0:
        [self pickLocation];
        break;
      case 1: // record
        [self attachRecordFollowingView: self.getLastView];
        break;
      case 2: // reminder
        [self addReminder];
        break;
      default:
        break;
    }
    
  }
}

- (BOOL)shouldAutorotateToInterfaceOrientation {
  return YES;
}

- (IBAction)titleFieldTextChanged:(id)sender {
  self.detailItem.title = self.titleField.text;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

- (void)resetRecordBtn
{
  [self.recordController removeTarget: nil
                               action: nil
                     forControlEvents:UIControlEventTouchUpInside];
  
  [self.recordController addTarget:self
                            action:@selector(recordAudio)
                  forControlEvents:UIControlEventTouchUpInside];
  [self.recordController setTitle:@" Record Audio"
                         forState:UIControlStateNormal];
}

- (void)resetStopRecordBtn
{
  [self.recordController setTitle:@" Stop Recording" forState:UIControlStateNormal];
  [self.recordController removeTarget: nil
                               action: nil
                     forControlEvents:UIControlEventTouchUpInside];
  
  [self.recordController addTarget:self
                            action:@selector(stopRecord)
                  forControlEvents:UIControlEventTouchUpInside];
}

- (void)resetPlayBtn
{
  [self.playBtn removeTarget: nil
                      action: nil
            forControlEvents:UIControlEventTouchUpInside];
  
  [self.playBtn addTarget: self
                   action: @selector(playAudio)
         forControlEvents:UIControlEventTouchUpInside];
  [self.playBtn setTitle:@" Play Audio"
                forState:UIControlStateNormal];
}

- (void)resetStopPlayBtn
{
  [self.playBtn removeTarget:nil
                      action:nil
            forControlEvents:UIControlEventTouchUpInside];
  
  [self.playBtn addTarget:self
                   action:@selector(stopPlay)
         forControlEvents:UIControlEventTouchUpInside];
  [self.playBtn setTitle:@" Stop Playing"
                forState:UIControlStateNormal];
}

- (void)removeAllBtns
{
  if(self.btns) {
    for(id btn in self.btns) {
      [btn removeFromSuperview];
    }
    self.btns = nil;
  }
  self.btns = [[NSMutableArray alloc]init];
}

- (void)attchLocationPickerFollowingView: (UIView*) view
{
  UIButton* btn = [UIButton buttonWithType:UIButtonTypeInfoLight];
  self.locationPicker = btn;
  [self.locationPicker addTarget:self
                          action:@selector(pickLocation)
                forControlEvents:UIControlEventTouchUpInside];
  self.locationPicker.frame = CGRectMake(CGRectGetMinX(view.frame),
                                         CGRectGetMaxY(view.frame) + 10,
                                         view.frame.size.width,
                                         30);
  [self.view addSubview:self.locationPicker];
  [self.locationPicker setTitle:self.detailItem.location?:@"Pick Location" forState:UIControlStateNormal];
  
  [self.btns addObject:btn];
}

- (void)attachRecordFollowingView: (UIView*) view
{
  UIButton* btn = [UIButton buttonWithType:UIButtonTypeInfoLight];
  self.recordController = btn;
  self.recordController.frame = CGRectMake(CGRectGetMinX(view.frame),
                                           CGRectGetMaxY(view.frame) + 0,
                                           view.frame.size.width,
                                           30);
  [self.view addSubview:self.recordController];
  [self resetRecordBtn];
  
  [self.btns addObject:btn];
}

- (void)attachPlayBtnFollowingView: (UIView*) view
{
  UIButton *btn = [UIButton buttonWithType:UIButtonTypeInfoLight];
  self.playBtn = btn;
  
  self.playBtn.frame = CGRectMake(CGRectGetMinX(view.frame),
                                  CGRectGetMaxY(view.frame) + 0,
                                  view.frame.size.width,
                                  30);
  
  [self.view addSubview:self.playBtn];
  [self resetPlayBtn];
  
  [self.btns addObject:btn];
}

- (void)attachRemindFollowingView: (UIView*) view
{
  UIButton *btn = [UIButton buttonWithType:UIButtonTypeInfoLight];
  self.remindBtn = btn;
  
  self.remindBtn.frame = CGRectMake(CGRectGetMinX(view.frame),
                                    CGRectGetMaxY(view.frame) + 0,
                                    view.frame.size.width,
                                    30);
  
  

  [self.remindBtn setTitle:self.detailItem.reminder.date
                  forState:UIControlStateNormal];
  [self.remindBtn addTarget:self
                     action:@selector(addReminder)
           forControlEvents:UIControlEventTouchUpInside];
  
  [self.view addSubview:self.remindBtn];
  [self.btns addObject:btn];
}

- (void)attachAddMoreFollowingView: (UIView*) view
{
  UIButton* btn = [UIButton buttonWithType:UIButtonTypeInfoLight];
  self.addMoreBtn = btn;
  self.addMoreBtn.frame = CGRectMake(CGRectGetMinX(view.frame),
                                     CGRectGetMaxY(view.frame) + 0,
                                     view.frame.size.width,
                                     30);
  
  [self.view addSubview:self.addMoreBtn];
  [self.addMoreBtn setTitle:@"Add More" forState:UIControlStateNormal];
  [self.addMoreBtn addTarget: self
                   action: @selector(attachActionSheetForMore)
         forControlEvents:UIControlEventTouchUpInside];
  
  [self.btns addObject: btn];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  
  // disable back gesture
  if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
  }
  
  // Setup audio session
  AVAudioSession *session = [AVAudioSession sharedInstance];
  [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
  
  // Setup swipe gesture
  UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideToRightWithGestureRecognizer:)];
  swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
  
  UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(slideToLeftWithGestureRecognizer:)];
  swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
  
  [self.view addGestureRecognizer: swipeRight];
  [self.view addGestureRecognizer: swipeLeft];
}

- (void) viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
  [self configureView];
}

-(void)alertNoMore
{
  UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Info"
                                                        message:@"Nothing More :<"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
  
  [myAlertView show];
}

-(void)slideToRightWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer
{
  NSLog(@"%s", __FUNCTION__);
  if([self setItemIndex: m_index - 1]) {
    [self configureView];
  } else {
    [self alertNoMore];
  }
}

-(void)slideToLeftWithGestureRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer
{
  NSLog(@"%s", __FUNCTION__);
  if([self setItemIndex: m_index + 1]) {
    [self configureView];
  } else {
    [self alertNoMore];
  }
}

- (void)addReminder
{
  [self.navigationController pushViewController:[[ReminderViewController alloc] initWithDelegate:self
                                                                                        withText:self.detailItem.title]
                                       animated:YES] ;

}

- (void)pickLocation
{
  [self.navigationController pushViewController:[[LocationPickerController alloc] initWithDelegate:self
                                                                                        searchText:self.detailItem.location]
                                       animated:YES] ;
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

- (IBAction)addPictureTapped:(id)sender {
  [self attachmentActionSheetForPic];
}

- (void) recordAudio
{
  // Set the audio file
  curAudioPath = [NSString stringWithFormat:@"%d.m4a", (int)[[NSDate date] timeIntervalSince1970]];
  NSURL *outputFileURL = [RWTAppDelegate getFullPath:curAudioPath];
  
  // Define the recorder setting
  NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
  
  [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
  [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
  [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
  
  // Initiate and prepare the recorder
  NSLog(@"record to %@", outputFileURL);
  recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
  recorder.delegate = self;
  recorder.meteringEnabled = YES;
  [recorder prepareToRecord];
  
  // record now
  AVAudioSession *session = [AVAudioSession sharedInstance];
  [session setActive:YES error:nil];
  
  // Start recording
  [recorder record];
  
  // no play!
  [self.playBtn setEnabled:NO];

  // replace btn
  [self resetStopRecordBtn];
}

- (void) stopRecord
{
  [recorder stop];
  
  AVAudioSession *audioSession = [AVAudioSession sharedInstance];
  [audioSession setActive:NO error:nil];
}

- (void) playAudio {
  NSURL *outputFileURL = [RWTAppDelegate getFullPath: self.detailItem.audioPath];
  NSLog(@"play %@", outputFileURL);
  player = [[AVAudioPlayer alloc] initWithContentsOfURL:outputFileURL  error:nil];
  [player setDelegate:self];
  [player play];
  
  // no record
  [self.recordController setEnabled:NO];
  
  // replace btn
  [self resetStopPlayBtn];
}

- (void) stopPlay
{
  [player stop];
  
  [self resetPlayBtn];
  [self.recordController setEnabled:YES];
}
#pragma mark UIImagePickerControllerDelegate

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
  
  UIImage *fullImage = (UIImage *) [info objectForKey:UIImagePickerControllerEditedImage];
  
  // 1) Show status
  [SVProgressHUD showWithStatus:@"Resizing image..."];
  
  // 2) Get a concurrent queue form the system
  dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  
  // 3) save/resize image in background
  dispatch_async(concurrentQueue, ^{
    NSData *imageData = UIImagePNGRepresentation(fullImage);
    
    NSString *imagePath = [NSString stringWithFormat:@"%d.png", (int)[[NSDate date] timeIntervalSince1970]];
    NSString *pathToWrite = [RWTAppDelegate getFullPathForImage: imagePath];
    
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

- (void)selectLocationCoordinate:(CLLocationCoordinate2D)coordinate
{
  self.detailItem.location = [NSString stringWithFormat:@" %f, %f", coordinate.latitude, coordinate.longitude];
  // willappear
}

- (void)selectLocation:(NSString *)location coordinate:(CLLocationCoordinate2D)coordinate
{
  self.detailItem.location =  [NSString stringWithFormat:@" %@, %f, %f", location, coordinate.latitude, coordinate.longitude];
  // willappear
}

- (void)setReminderDate:(NSDate*)date repeatInterval:(NSCalendarUnit)repeatInterval
{
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"yyyy/MM/dd hh:mm:ss"];
  [formatter setTimeZone:[NSTimeZone localTimeZone]];
  
  self.detailItem.reminder = [[ReminderData alloc] initWithDate: [formatter stringFromDate:date]];
  // willappear
}

#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag {
  [self.detailItem setAudioPath:curAudioPath];
  
  [self configureView];
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
  [self resetPlayBtn];
}

@end
