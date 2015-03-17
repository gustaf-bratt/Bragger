//
//  MACommentsViewController.h
//  Bragger
//
//  Created by GaoShen on 2/5/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "MAcustomViewController.h"
#import "Customecell.h"
#import "MBProgressHUD.h"

@interface MACommentsViewController : UIViewController<UINavigationControllerDelegate,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate, MBProgressHUDDelegate>
{
//    MAcustomViewController *FirstTable;
    MBProgressHUD *HUD;
}

@property (nonatomic) IBOutlet Customecell *newcustom_Cell;
@property (assign) BOOL myProperty;
@property (nonatomic) BOOL isFollowing;
@property (nonatomic, retain) NSString *str_RealName;
@property (nonatomic, retain) NSString *str_Location;
@property (nonatomic, retain) NSString *str_PostTitle;
@property (nonatomic, retain) NSString *str_HashTag;
@property (nonatomic, retain) NSString *str_UserImagePath;
@property (nonatomic, retain) NSString *str_TotalPost4Like;
@property (nonatomic, retain) NSString *str_TotalShowOff;
@property (nonatomic, retain) NSString *str_postedImageUrl;
@property (nonatomic, retain) NSString *str_TotalRebrag;
@property (nonatomic, retain) NSString *postId;
@property (nonatomic, retain) NSString *PostOwnerUserId;
@property (nonatomic, retain) NSString *str_Like;
@property (nonatomic, retain) NSString *str_ShowOff;
@property (nonatomic, retain) NSString *str_Rebrag;

@property (weak, nonatomic) IBOutlet UITableView *tbl_Comment;
@property (weak, nonatomic) IBOutlet UITextField *txt_COmmentBragText;
@property (weak, nonatomic) IBOutlet UILabel *lbl_TotalPost4Like;
@property (weak, nonatomic) IBOutlet UILabel *lbl_TotalShowOff;
@property (weak, nonatomic) IBOutlet UILabel *lbl_RealName;
@property (weak, nonatomic) IBOutlet UILabel *lbl_PostTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbl_HashTag;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Location;
@property (weak, nonatomic) IBOutlet UIImageView *img_UserImage;
@property (weak, nonatomic) IBOutlet UIImageView *img_PostedImage;
@property (weak, nonatomic) IBOutlet UILabel *lbl_Rebrag;
@property (weak, nonatomic) IBOutlet UIButton *btn_Follow;
@property (weak, nonatomic) IBOutlet UIImageView *img_PostComment;
@property (weak, nonatomic) IBOutlet UIButton *likeBtn;
@property (weak, nonatomic) IBOutlet UIButton *rebragBtn;
@property (weak, nonatomic) IBOutlet UIButton *showOffBtn;
@property (weak, nonatomic) IBOutlet UIButton *likeBtnSmall;
@property (weak, nonatomic) IBOutlet UIButton *rebragBtnSmall;
@property (weak, nonatomic) IBOutlet UIButton *showOffBtnSmall;
@property (weak, nonatomic) IBOutlet UIImageView *img_PinLocation;


- (IBAction)HdKeyboard:(id)sender;
- (IBAction)act_PhotoComment:(id)sender;
- (IBAction)act_PostComment:(id)sender;
- (IBAction)act_follow:(id)sender;
- (IBAction)act_like:(id)sender;
- (IBAction)act_Rebrag:(id)sender;
- (IBAction)act_ShowOff:(id)sender;
- (IBAction)act_likeSmall:(id)sender;
- (IBAction)act_RebragSmall:(id)sender;
- (IBAction)actShowOffSmall:(id)sender;
- (IBAction)act_Back:(id)sender;




@end
