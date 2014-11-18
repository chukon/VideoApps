//
//  VIDEOViewController.m
//  VideoApps
//
//  Created by Charles Konkol on 11/17/14.
//  Copyright (c) 2014 Rock Valley College. All rights reserved.
//

#import "VIDEOViewController.h"

@interface VIDEOViewController ()

@end
NSString *vidlink;
NSString *filePaths;
@implementation VIDEOViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (self.videodb) {
        [self.txtName setText:[self.videodb valueForKey:@"name"]];
        vidlink=[self.videodb valueForKey:@"link"];
        [self.txtDate setText:[self.videodb valueForKey:@"datestamp"]];
        self.btnRecord.hidden = YES;
          self.btnPlay.hidden = NO;
        self.txtDate.hidden = NO;
       // NSLog(@"Date is: %@", [self.videodb valueForKey:@"date"]);
        
        // [self.txturl setText:[self.videodb valueForKey:@"vm_date"]];
    }
    else
    {
         self.txtDate.hidden = YES;
        self.btnRecord.hidden = NO;
        self.btnPlay.hidden = YES;
    }

    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    
    [self.view addGestureRecognizer:tap];

    // Do any additional setup after loading the view.
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
        [self.videodb setValue:strDate forKey:@"datestamp"];
        [self.videodb setValue:vidlink forKey:@"link"];
    } else {
        // Create a new device
        NSManagedObject *newDevice = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"VideoFiles" inManagedObjectContext:context];
        [newDevice setValue:self.txtName.text forKey:@"name"];
        [newDevice setValue:strDate forKey:@"datestamp"];
        [newDevice setValue:vidlink forKey:@"link"];
        
        
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
    
    //  [self dismissViewControllerAnimated:YES completion:nil];

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
    
    // find Documents directory
    NSURL *documentsURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
    
    // append a file name to it
    documentsURL = [documentsURL URLByAppendingPathComponent:fileName];
    
    return documentsURL;
}
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    // NSString *file;
    // grab our movie URL
    NSURL *chosenMovie = [info objectForKey:UIImagePickerControllerMediaURL];
    NSString *random1 = [self getRandomPINString:8];
    // save it to the documents directory
    vidlink= [NSString stringWithFormat:@"%@%@.mov", random1,self.txtName.text];
    
    //file=[NSString stringWithFormat:@"%@%@", random1,self.txtName.text];
    NSURL *fileURL = [self grabFileURL:vidlink];
    //NSURL *URLfile =[self grabFileURL:file];
    NSData *movieData = [NSData dataWithContentsOfURL:chosenMovie];
    [movieData writeToURL:fileURL atomically:YES];
   filePaths = [fileURL absoluteString];
   
    // save it to the Camera Roll
    UISaveVideoAtPathToSavedPhotosAlbum([chosenMovie path], nil, nil, nil);
    [self SaveVideo];
    // and dismiss the picker
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

- (IBAction)btnBack:(id)sender {
    
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnEdit:(id)sender {
}
- (IBAction)btnRecord:(id)sender {
    if ([self.txtName.text  isEqual: @""] || [self.txtName.text  isEqual: @"ENTER NAME FOR VIDEO"] )
    {
        self.txtName.text = @"ENTER NAME FOR VIDEO";
    }
    else
    {
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.delegate = self;
        picker.allowsEditing = NO;
        
        NSArray *mediaTypes = [[NSArray alloc]initWithObjects:(NSString *)kUTTypeMovie, nil];
        
        picker.mediaTypes = mediaTypes;
        
        [self presentViewController:picker animated:YES completion:nil];
        
    } else {
        
        UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:@"I'm afraid there's no camera on this device!" delegate:nil cancelButtonTitle:@"Dang!" otherButtonTitles:nil, nil];
        [alertView show];
    }

 
    }
       
}
- (IBAction)btnPlay:(id)sender {
    // pick a video from the documents directory
    NSURL *video = [self grabFileURL:vidlink];
    
    // create a movie player view controller
    MPMoviePlayerViewController * controller = [[MPMoviePlayerViewController alloc]initWithContentURL:video];
    [controller.moviePlayer prepareToPlay];
    [controller.moviePlayer play];
    
    // and present it
    [self presentMoviePlayerViewControllerAnimated:controller];
}
@end
