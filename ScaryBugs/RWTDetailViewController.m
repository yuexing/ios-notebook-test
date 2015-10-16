//
//  RWTDetailViewController.m
//

#import "RWTDetailViewController.h"
#import "RWTScaryBugDoc.h"
#import "RWTUIImageExtras.h"
#import "SVProgressHUD.h"

#import "RWTAppDelegate.h"
#import "LocationPickerController.h"

#import <AVFoundation/AVFoundation.h>


@interface RWTDetailViewController () <LocationPickerControllerDelegate, AVAudioRecorderDelegate, AVAudioPlayerDelegate> {
  AVAudioRecorder *recorder;
  AVAudioPlayer *player;
  
  NSString *curAudioPath;
}
- (void)configureView;

@property (strong, nonatomic) UIActionSheet *attachmentMenuSheet;

@property (strong, nonatomic) UIButton *locationPicker;

@property (strong, nonatomic) UIButton *recordController;

@property (strong, nonatomic) UIButton *playBtn;

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
  if (self.detailItem) {
    self.titleField.text = self.detailItem.title;
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

- (void)resetRecordBtn
{
  [self.recordController removeTarget:self
                               action: @selector(stopRecord)
                     forControlEvents:UIControlEventTouchUpInside];
  
  [self.recordController addTarget:self
                            action: @selector(recordAudio)
                  forControlEvents:UIControlEventTouchUpInside];
  [self.recordController setTitle:@" Record Audio"
                         forState:UIControlStateNormal];
}

- (void)resetStopRecordBtn
{
  [self.recordController setTitle:@" Stop Recording" forState:UIControlStateNormal];
  [self.recordController removeTarget:self
                               action:@selector(recordAudio)
                     forControlEvents:UIControlEventTouchUpInside];
  
  [self.recordController addTarget:self
                            action:@selector(stopRecord)
                  forControlEvents:UIControlEventTouchUpInside];
}

- (void)resetPlayBtn
{
  [self.playBtn removeTarget:self
                      action: @selector(stopPlay)
            forControlEvents:UIControlEventTouchUpInside];
  
  [self.playBtn addTarget:self
                    action: @selector(playAudio)
          forControlEvents:UIControlEventTouchUpInside];
  [self.playBtn setTitle:@" Play Audio"
                 forState:UIControlStateNormal];
}

- (void)resetStopPlayBtn
{
  [self.playBtn removeTarget:self
                      action:@selector(playAudio)
            forControlEvents:UIControlEventTouchUpInside];
  
  [self.playBtn addTarget:self
                   action:@selector(stopPlay)
         forControlEvents:UIControlEventTouchUpInside];
  [self.playBtn setTitle:@" Stop Playing"
                forState:UIControlStateNormal];
}

- (void)attachPlayBtn
{
  if(!self.playBtn) {
    self.playBtn = [UIButton buttonWithType:UIButtonTypeInfoLight];
    
    self.playBtn.frame = CGRectMake(CGRectGetMinX(self.recordController.frame),
                                    CGRectGetMaxY(self.recordController.frame) + 0,
                                    self.recordController.frame.size.width,
                                    30);
    
    [self.view addSubview:self.playBtn];
  }
  [self resetPlayBtn];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  // Do any additional setup after loading the view, typically from a nib.
  [self configureView];
  
  self.locationPicker = [UIButton buttonWithType:UIButtonTypeInfoLight];
  [self.locationPicker addTarget:self
             action:@selector(pickLocation)
   forControlEvents:UIControlEventTouchUpInside];
  [self.locationPicker setTitle:self.detailItem.location?: @" Pick Location" forState:UIControlStateNormal];
  self.locationPicker.frame = CGRectMake(CGRectGetMinX(self.imageView.frame),
                                         CGRectGetMaxY(self.imageView.frame) + 10,
                                         self.imageView.frame.size.width,
                                         30);
  [self.view addSubview:self.locationPicker];
  
  
  self.recordController = [UIButton buttonWithType:UIButtonTypeInfoLight];
  self.recordController.frame = CGRectMake(CGRectGetMinX(self.locationPicker.frame),
                                         CGRectGetMaxY(self.locationPicker.frame) + 0,
                                         self.locationPicker.frame.size.width,
                                         30);
  [self resetRecordBtn];
  [self.view addSubview:self.recordController];
  
  if(self.detailItem.audioPath) {
    [self attachPlayBtn];
  }
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

- (void) recordAudio
{
  // Set the audio file
  curAudioPath = [NSString stringWithFormat:@"%d.m4a", (int)[[NSDate date] timeIntervalSince1970]];
  NSURL *outputFileURL = [RWTAppDelegate getUrl:curAudioPath];
  
  // Setup audio session
  AVAudioSession *session = [AVAudioSession sharedInstance];
  [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
  
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
  NSURL *outputFileURL = [RWTAppDelegate getUrl: self.detailItem.audioPath];
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
  
  UIImage *fullImage = (UIImage *) [info objectForKey:UIImagePickerControllerOriginalImage];
  
  // 1) Show status
  [SVProgressHUD showWithStatus:@"Resizing image..."];
  
  // 2) Get a concurrent queue form the system
  dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
  
  // 3) save/resize image in background
  dispatch_async(concurrentQueue, ^{
    NSData *imageData = UIImagePNGRepresentation(fullImage);
    
    NSString *imagePath = [NSString stringWithFormat:@"%d.png", (int)[[NSDate date] timeIntervalSince1970]];
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

- (void)selectLocationCoordinate:(CLLocationCoordinate2D)coordinate
{
  self.detailItem.location = [NSString stringWithFormat:@" %f, %f", coordinate.latitude, coordinate.longitude];
  [self.locationPicker setTitle:self.detailItem.location forState:UIControlStateNormal];
}

- (void)selectLocation:(NSString *)location coordinate:(CLLocationCoordinate2D)coordinate
{
  self.detailItem.location =  [NSString stringWithFormat:@" %@, %f, %f", location, coordinate.latitude, coordinate.longitude];
  [self.locationPicker setTitle:self.detailItem.location forState:UIControlStateNormal];
}

#pragma mark - AVAudioRecorderDelegate

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag {
  [self.detailItem setAudioPath:curAudioPath];
  [self resetRecordBtn];
  [self attachPlayBtn];
  
  [self.playBtn setEnabled:YES];
}

#pragma mark - AVAudioPlayerDelegate

- (void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag {
  
  [self.recordController setEnabled:YES];
  
}

@end
