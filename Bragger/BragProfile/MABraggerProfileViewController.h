//
//  MABraggerProfileViewController.h
//  Bragger
//
//  Created by GaoShen on 2/3/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MABraggerProfileCustomCell.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
@interface MABraggerProfileViewController : UIViewController<UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,AVAudioPlayerDelegate,NSURLConnectionDelegate>
{
	

}
@property (strong, nonatomic) MPMoviePlayerController *movieController;
@property (retain, nonatomic) NSString *str_SelectedUserId;
@property (nonatomic, retain) IBOutlet MABraggerProfileCustomCell *customCell;
@property (weak, nonatomic) IBOutlet UITextField *txt_CommantbragTxt;
@property (weak, nonatomic) IBOutlet UILabel *lbl_BraggerName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_BraggerLocation;
@property (weak, nonatomic) IBOutlet UIImageView *img_BraggerUserImage;
@property (weak, nonatomic) IBOutlet UILabel *lbl_TotalFollowing;
@property (weak, nonatomic) IBOutlet UILabel *lbl_TotalFollowers;
@property (weak, nonatomic) IBOutlet UILabel *lbl_TotalBrags;
@property (weak, nonatomic) IBOutlet UIButton *btn_AddFollowers;
@property (weak, nonatomic) IBOutlet UITableView *tbl_BraggerProfilePost;
@property (weak, nonatomic) IBOutlet UIImageView *img_PinLocation;
@property (nonatomic) BOOL isFollowing;

- (IBAction)act_Followers:(id)sender;
- (IBAction)HdKeyboard:(id)sender;
- (IBAction)act_Bragging:(id)sender;
- (IBAction)act_SHareBrag:(id)sender;
- (IBAction)act_Braggers:(id)sender;
- (IBAction)act_BackButtonProfile:(id)sender;


@end
