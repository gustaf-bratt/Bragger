//
//  MABragVideoViewController.h
//  Bragger
//
//  Created by GaoShen on 2/2/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MBProgressHUD.h"
@interface MABragVideoViewController : UIViewController<UITextViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,MBProgressHUDDelegate>
{
 MBProgressHUD *HUD;
}

@property(assign) unsigned int view2;
@property (copy,   nonatomic) NSURL *movieURL;
@property (strong, nonatomic) MPMoviePlayerController *movieController;

@property (weak, nonatomic) IBOutlet UITextView *txtvw_COmmentTextView;
@property (weak, nonatomic) IBOutlet UIView *view_VideoTagView;
@property (weak, nonatomic) IBOutlet UIView *view_VideoFriendsView;
@property (weak, nonatomic) IBOutlet UIButton *btn_Privacy;
@property (weak, nonatomic) IBOutlet UITextField *txt_HashTag;


- (IBAction)act_TakeVideo:(id)sender;
- (IBAction)act_UploadVideo:(id)sender;
- (IBAction)act_Tag:(id)sender;
- (IBAction)act_Friends:(id)sender;
- (IBAction)act_PostVideo:(id)sender;
- (IBAction)act_CloseVideo:(id)sender;
- (IBAction)act_Public:(id)sender;
- (IBAction)act_FriendsExceptAcq:(id)sender;
- (IBAction)act_hashTagDone:(id)sender;

@end
