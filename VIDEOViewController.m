//
//  VIDEOViewController.m
//  VideoApps
//
//  Created by Charles Konkol on 11/17/14.
//  Copyright (c) 2014 Rock Valley College. All rights reserved.
//

#import "VIDEOViewController.h"



@interface VIDEOViewController ()
{
    MPMoviePlayerController *moviePlayerController;

    NSArray *pickerData;
    
}
@property (weak, nonatomic) IBOutlet UIView *movieView;
@end
NSString *vidlink;
NSString *vidlink2;
NSString *filePaths;
NSString *SaveMsg;
AVPlayerItem *playerItem;
AVPlayer *player;
NSString *FilterType;
NSString *FilterTypeSelected;
GPUImageFilter *selectedFilter;
MPMoviePlayerViewController * controller;

CGAffineTransform transform;

@implementation VIDEOViewController
- (void) orientationChanged:(NSNotification *)notification
{
    // UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if(orientation == UIDeviceOrientationLandscapeLeft)
    {
        //CGAffineTransform transform = self.view.transform;
       // transform = CGAffineTransformRotate(transform, (M_PI/2.0));
       // picker.cameraOverlayView.transform = transform;
    }
    else if(orientation == UIDeviceOrientationLandscapeRight)
    {
       // picker.cameraOverlayView.transform = CGAffineTransformRotate(CGAffineTransformIdentity,117.81);
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Initialize Data
    pickerData = @[@"Select Filter",@"GreyScale", @"Sepia", @"Sketch", @"Pixellate", @"ColorInvert", @"Cartoon",@"Distortion"];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationChanged:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];

    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];
    self.lblmsg.hidden=YES;
    self.picker.hidden=YES;
    // Do any additional setup after loading the view.
    if (self.videodb) {
        [self.txtName setText:[self.videodb valueForKey:@"name"]];
        vidlink=[self.videodb valueForKey:@"link"];
        FilterType=@"";
        [self.txtDate setText:[self.videodb valueForKey:@"datestamp"]];
        self.btnRecord.hidden = YES;
         self.lblrecord.hidden=YES;
         self.btnEdit.enabled = YES;
         self.btnEdit.title = @"Filter";
          self.btnPlay.hidden = NO;
        self.txtDate.hidden = NO;
        SaveMsg=@"Video Updated";
       // NSLog(@"Date is: %@", [self.videodb valueForKey:@"date"]);
         self.txtDate.enabled = NO;
        self.txtName.enabled = NO;
        ////FILTER
        // Connect data
        self.picker.dataSource = self;
        self.picker.delegate = self;
        self.lblShare.hidden=NO;
        self.btnShare.hidden=NO;
        if ([self.txtName.text containsString:(@"-->")])
        {
            self.btnEdit.enabled = NO;
            self.btnEdit.title = @"";
        }
        [NSTimer scheduledTimerWithTimeInterval: 1.0  target: self selector: @selector(updatedates:) userInfo: nil repeats: NO];

    
    }
    else
    {
        self.lblShare.hidden=YES;
        self.btnShare.hidden=YES;
        self.lblplay.hidden=YES;
         self.btnPlay.hidden = YES;
        SaveMsg=@"Video Saved";
           self.btnEdit.enabled = NO;
         self.txtDate.hidden = YES;
        self.btnRecord.hidden = NO;
        self.lblrecord.hidden=NO;
       
         [self.txtName becomeFirstResponder];
    }

    // Do any additional setup after loading the view.
}
- (void) updatedates:(NSTimer*) t
{
    [self PlayNow];
}
-(void)dismissKeyboard {
    // add textfields and textviews
    //[Nameofoutletlikeatextfield resignFirstResponder];
    [self.txtName resignFirstResponder];
  
}
- (NSManagedObjectContext *)managedObjectContext {
    NSManagedObjectContext *context = nil;
    id delegate = [[UIApplication sharedApplication] delegate];
    if ([delegate performSelector:@selector(managedObjectContext)]) {
        context = [delegate managedObjectContext];
    }
    return context;
}
-(IBAction) doneEditing:(id) sender {
    [sender resignFirstResponder];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Delegate Methods

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    
    // user hit cancel
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void) SaveVideo
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    CFGregorianDate currentDate = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeGetCurrent(), CFTimeZoneCopySystem());
    NSString *strDate = [NSString stringWithFormat:@"%02d/%02d %02d:%02d:%2.0f", currentDate.month,currentDate.day,currentDate.hour, currentDate.minute, currentDate.second];
    
    if (self.videodb) {
        // Update existing device
        [self.videodb setValue:self.txtName.text forKey:@"name"];
       // [self.videodb setValue:strDate forKey:@"datestamp"];
       // [self.videodb setValue:filePaths forKey:@"link"];
       
        
    } else {
        // Create a new device
        NSManagedObject *newDevice = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"VideoFiles" inManagedObjectContext:context];
        [newDevice setValue:self.txtName.text forKey:@"name"];
        [newDevice setValue:strDate forKey:@"datestamp"];
        NSURL *fileURL = [self grabFileURL:vidlink];
        filePaths = [fileURL absoluteString];
        [newDevice setValue:filePaths forKey:@"link"];
        
        
    }
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
    
    // NSString *  filePath;
    // sleep(2);
    //[self UploadNow];
    //  sleep(2);
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
- (void) SaveVideo2
{
    NSString *FilterName;
    NSManagedObjectContext *context = [self managedObjectContext];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd/MM/yyyy HH:mm"];
    CFGregorianDate currentDate = CFAbsoluteTimeGetGregorianDate(CFAbsoluteTimeGetCurrent(), CFTimeZoneCopySystem());
    NSString *strDate = [NSString stringWithFormat:@"%02d/%02d %02d:%02d:%2.0f", currentDate.month,currentDate.day,currentDate.hour, currentDate.minute, currentDate.second];
    
    
        // Create a new device
        NSManagedObject *newDevice = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"VideoFiles" inManagedObjectContext:context];
  
        [newDevice setValue:self.txtName.text forKey:@"name"];
        [newDevice setValue:strDate forKey:@"datestamp"];
         NSURL *video =[NSURL fileURLWithPath:vidlink2];
      filePaths = [video absoluteString];
        [newDevice setValue:filePaths forKey:@"link"];
    
    NSError *error = nil;
    // Save the object to persistent store
    if (![context save:&error]) {
        NSLog(@"Can't Save! %@ %@", error, [error localizedDescription]);
    }
   

    
}


-(NSString *)getRandomPINString:(NSInteger)length
{
    NSMutableString *returnString = [NSMutableString stringWithCapacity:length];
    
    NSString *numbers = @"0123456789";
    
    // First number cannot be 0
    [returnString appendFormat:@"%C", [numbers characterAtIndex:(arc4random() % ([numbers length]-1))+1]];
    
    for (int i = 1; i < length; i++)
    {
        [returnString appendFormat:@"%C", [numbers characterAtIndex:arc4random() % [numbers length]]];
    }
    
    return returnString;
}


- (NSURL*)grabFileURL:(NSString *)fileName {
    //  NSString *pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
    
    // find Documents directory
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    // append a file name to it
    documentsURL = [documentsURL URLByAppendingPathComponent:fileName];
    
    return documentsURL;
}
 -(int)drawFrameOnMainThread{
    
     return 0;
 }

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *chosenMovie = [info objectForKey:UIImagePickerControllerMediaURL];
    NSString *random1 = [self getRandomPINString:8];
    // save it to the documents directory
    vidlink= [NSString stringWithFormat:@"%@%@.m4v", random1,self.txtName.text];
    NSURL *fileURL = [self grabFileURL:vidlink];
    NSData *movieData = [NSData dataWithContentsOfURL:chosenMovie];
    [movieData writeToURL:fileURL atomically:YES];
    // save it to the Camera Roll
    UISaveVideoAtPathToSavedPhotosAlbum([chosenMovie path], nil, nil, nil);
    [self SaveVideo];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnBack:(id)sender {
    
   
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (CGSize) getScreenSize
{
    //Get Screen size
    CGSize size;
    if (UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation) && [[UIScreen mainScreen] bounds].size.height > [[UIScreen mainScreen] bounds].size.width) {
        // in Landscape mode, width always higher than height
        size.width = [[UIScreen mainScreen] bounds].size.height;
        size.height = [[UIScreen mainScreen] bounds].size.width;
    } else if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation) && [[UIScreen mainScreen] bounds].size.height < [[UIScreen mainScreen] bounds].size.width) {
        // in Portrait mode, height always higher than width
        size.width = [[UIScreen mainScreen] bounds].size.height;
        size.height = [[UIScreen mainScreen] bounds].size.width;
    } else {
        // otherwise it is normal
        size.height = [[UIScreen mainScreen] bounds].size.height;
        size.width = [[UIScreen mainScreen] bounds].size.width;
    }
    return size;
}

- (void) gs
{
    FilterType=FilterTypeSelected;
   //  NSURL *video = [[NSURL alloc] initWithString:vidlink];
    NSURL *video =[[NSURL alloc] initWithString:vidlink];
    NSURL *videoURL = video;
    
    movieFile = [[GPUImageMovie alloc] initWithURL:videoURL];
    movieFile.runBenchmark = YES;
    movieFile.playAtActualSpeed = YES;
    //filter = [[GPUImageSepiaFilter alloc] init];
    filter = selectedFilter;
    [movieFile addTarget:filter];
    //Save File
    NSString *random1 = [self getRandomPINString:8];
    NSString *pathToMovie1 = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    vidlink2= [NSString stringWithFormat:@"%@/%@%@-%@.m4v", pathToMovie1,random1,self.txtName.text,FilterType];
    NSString *pathToMovie = vidlink2;
    unlink([pathToMovie UTF8String]);
    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
    
    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:CGSizeMake(640.0, 480.0)];
    [filter addTarget:movieWriter];
    
    movieWriter.shouldPassthroughAudio = YES;
    movieFile.audioEncodingTarget = movieWriter;
    
    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
 
    [movieWriter startRecording];
    [movieFile startProcessing];
    timer = [NSTimer scheduledTimerWithTimeInterval:0.3f
                                             target:self
                                           selector:@selector(retrievingProgress)
                                           userInfo:nil
                                            repeats:YES];

    
    [movieWriter setCompletionBlock:^{
        [filter removeTarget:movieWriter];
        [movieWriter finishRecording];
        NSURL *fileURL = [[NSURL alloc] initWithString:vidlink2];
        NSData *movieData = [NSData dataWithContentsOfURL:movieURL];
        [movieData writeToURL:fileURL atomically:YES];
        // save it to the Camera Roll
        UISaveVideoAtPathToSavedPhotosAlbum([movieURL path], nil, nil, nil);
        [self SaveVideo2];
        sleep(5);
        self.progressLabel.text=@"";
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}
- (void)retrievingProgress
{
    self.progressLabel.text = [NSString stringWithFormat:@"%d%%", (int)(movieFile.progress * 90)];
}
- (IBAction)btnEdit:(id)sender {
    if (self.lblmsg.hidden==YES)
    {
        self.lblmsg.hidden=NO;
        self.picker.hidden=NO;
        self.btnRecord.hidden = YES;
        self.btnPlay.hidden = YES;
         self.btnShare.hidden = YES;
    }
    else
    {
        self.lblmsg.hidden=YES;
        self.picker.hidden=YES;
        //self.btnRecord.hidden = NO;
        self.btnPlay.hidden = NO;
        self.btnShare.hidden = NO;
    }
      if ([self.btnEdit.title isEqual:@"Apply Filter"])
    {
        self.txtName.text=[NSString stringWithFormat:@"%@-->%@", self.txtName.text,FilterTypeSelected];
         self.lblmsg.hidden=YES;

    self.picker.hidden=YES;
    [self gs];
    }
    
}
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 1234) {
        // do stuff
        CGFloat scaleFactor=1.3f;
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.showsCameraControls = YES;
        NSArray *mediaTypes = [[NSArray alloc]initWithObjects:(NSString *)kUTTypeMovie, nil];
        picker.mediaTypes = mediaTypes;
        picker.cameraViewTransform = CGAffineTransformScale(CGAffineTransformMakeRotation(M_PI * -90 / 180.0), scaleFactor, scaleFactor);
        picker.view.transform = CGAffineTransformMakeRotation(M_PI_2);
        [self presentViewController:picker animated:YES completion:nil];
    }
}

- (IBAction)btnRecord:(id)sender {
    if ([self.txtName.text  isEqual: @""] || [self.txtName.text  isEqual: @"ENTER NAME FOR VIDEO"] )
    {
        self.txtName.text = @"ENTER NAME FOR VIDEO";
    }
    else
    {
        
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"Please turn phone to left [Landscape]" delegate:self cancelButtonTitle:nil otherButtonTitles:nil, nil];
            alertView.tag = 1234;
             [alertView addButtonWithTitle:@"OK"];
            [alertView show];
        } else {
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"I'm afraid there's no camera on this device!" delegate:nil cancelButtonTitle:@"Dang!" otherButtonTitles:nil, nil];
            [alertView show];
            
        }
    }
    

    
}

- (void) PlayNow{
     NSURL *video = [[NSURL alloc] initWithString:vidlink];
    // create a movie player view controller
    controller = [[MPMoviePlayerViewController alloc]initWithContentURL:video];
       [controller.moviePlayer prepareToPlay];
    [controller.moviePlayer play];
    
    // and present it
    [self presentMoviePlayerViewControllerAnimated:controller];
}
- (IBAction)btnPlay:(id)sender {
    [self PlayNow];
   
}

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return pickerData.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return pickerData[row];
} 
// Catpure the picker view selection
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    // This method is triggered whenever the user makes a change to the picker selection.
    // The parameter named row and component represents what was selected.
    switch (row) {
        case 1:
            selectedFilter = [[GPUImageGrayscaleFilter alloc] init];
            self.btnEdit.Title = @"Apply Filter";
            FilterTypeSelected=@"Grayscale";
            break;
        case 2:
            selectedFilter = [[GPUImageSepiaFilter alloc] init];
              FilterTypeSelected=@"Sepia";
             self.btnEdit.Title = @"Apply Filter";
            break;
        case 3:
            selectedFilter = [[GPUImageSketchFilter alloc] init];
             self.btnEdit.Title = @"Apply Filter";
              FilterTypeSelected=@"Sketch";
            break;
        case 4:
            selectedFilter = [[GPUImagePixellateFilter alloc] init];
             self.btnEdit.Title = @"Apply Filter";
              FilterTypeSelected=@"Pixellate";
            break;
        case 5:
            selectedFilter = [[GPUImageColorInvertFilter alloc] init];
             self.btnEdit.Title = @"Apply Filter";
              FilterTypeSelected=@"ColorInvert";
            break;
        case 6:
            selectedFilter = [[GPUImageToonFilter alloc] init];
             self.btnEdit.Title = @"Apply Filter";
              FilterTypeSelected=@"Cartoon";
            break;
        case 7:
            selectedFilter = [[GPUImagePinchDistortionFilter alloc] init];
             self.btnEdit.Title = @"Apply Filter";
              FilterTypeSelected=@"Distortion";
        case 0:
            selectedFilter = [[GPUImageFilter alloc] init];
            self.btnEdit.Title = @"Filter";
            FilterTypeSelected=@"";
            break;
        default:
            break;
    }
}

- (IBAction)btnShare:(id)sender {
    //Test
    NSString *text = [NSString stringWithFormat:@"App: Video Filter Fun! \nCheck out my video:%@\n\n%@\n%@", self.txtName.text,@"Thanks for Sharing",@"www.myrvc.org"];
    //URL
  //NSURL *url =  [[NSURL alloc] initWithString:@"www.MyRVC.org"];
    //Image: in your project
   // UIImage *image = [UIImage imageNamed:@"video_record-512.png"];
    
  NSURL *videoPath = [[NSURL alloc] initWithString:vidlink];
    
    NSArray *objectsToShare = [NSArray arrayWithObjects:text, videoPath,  nil];
    //Initiate UIActivity Controller
    UIActivityViewController *controller =
    [[UIActivityViewController alloc]
     initWithActivityItems:objectsToShare
     applicationActivities:nil];
    
    //Start Share Box
    [self presentViewController:controller animated:YES completion:nil];
    
}
@end
