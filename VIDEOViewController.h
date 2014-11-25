//
//  VIDEOViewController.h
//  VideoApps
//
//  Created by Charles Konkol on 11/17/14.
//  Copyright (c) 2014 Rock Valley College. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "AppDelegate.h"
#import "GPUImage.h"


@interface VIDEOViewController : UIViewController <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPickerViewDataSource, UIPickerViewDelegate>
{
    GPUImageMovie *movieFile;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
    NSTimer * timer;
    

}
- (IBAction)btnBack:(id)sender;
- (IBAction)btnEdit:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *txtName;
- (IBAction)btnRecord:(id)sender;
-(IBAction) doneEditing:(id) sender;
@property (strong) NSManagedObject * videodb;
@property (weak, nonatomic) IBOutlet UIButton *btnRecord;
@property (weak, nonatomic) IBOutlet UITextField *txtDate;
@property (weak, nonatomic) IBOutlet UIButton *btnPlay;
- (IBAction)btnPlay:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnEdit;
@property (weak, nonatomic) IBOutlet UILabel *progressLabel;
@property (weak, nonatomic) IBOutlet UIButton *btngs;
- (IBAction)btngs:(id)sender;
@property (weak, nonatomic) IBOutlet UIPickerView *picker;
@property (weak, nonatomic) IBOutlet UILabel *lblmsg;

@end
