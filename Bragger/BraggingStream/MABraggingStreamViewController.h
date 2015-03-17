//
//  MABraggingStreamViewController.h
//  Bragger
//
//  Created by GaoShen on 2/2/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "MABraggingStreamCustomCell.h"
#import <CoreLocation/CoreLocation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MBProgressHUD.h"

@interface MABraggingStreamViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate,CLLocationManagerDelegate,NSURLConnectionDelegate,UIAlertViewDelegate, MBProgressHUDDelegate, UIScrollViewDelegate>
{
    UITableView     *tbl_Braggers;
    int             displayedCount;
    MBProgressHUD *HUD;
}
@property(assign) unsigned int REGUSER;
@property (strong, nonatomic) MPMoviePlayerController *movieController;
@property (nonatomic, retain) IBOutlet MABraggingStreamCustomCell *customCell;
//@property (weak, nonatomic) IBOutlet UITableView *tbl_Braggers;
@property (weak, nonatomic) IBOutlet UISegmentedControl *seg_BraggerStreamSegment;
@property (weak, nonatomic) IBOutlet UIImageView *img_FullScreen;
@property (weak, nonatomic) IBOutlet UIButton *btn_ExitFullScreen;
@property (weak, nonatomic) IBOutlet UILabel *lbl_FollowersStatus;
@property (strong, nonatomic) UIImage *FrameImage;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)act_Bragging:(id)sender;
- (IBAction)act_Braggers:(id)sender;
- (IBAction)act_ShareBrag:(id)sender;
- (IBAction)act_ChangeSegment:(id)sender;
- (IBAction)act_Settings:(id)sender;
- (IBAction)act_ExitFromFullScreen:(id)sender;




@end
