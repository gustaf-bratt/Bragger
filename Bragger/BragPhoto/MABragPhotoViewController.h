//
//  MABragPhotoViewController.h
//  Bragger
//
//  Created by GaoShen on 2/2/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
@interface MABragPhotoViewController : UIViewController<UITextViewDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate ,UINavigationControllerDelegate,MBProgressHUDDelegate,UITextFieldDelegate>
{
    
 
 MBProgressHUD *HUD;
}


@property(assign) unsigned int view2;
@property(strong,nonatomic) NSString *str_UserID;
@property(strong,nonatomic) NSString *str_SessionID;
@property(strong,nonatomic) NSDictionary *BragUserDetails2;


@property (weak, nonatomic) IBOutlet UITextView *txtView_Comment;
@property (weak, nonatomic) IBOutlet UIImageView *img_Choosed;
@property (weak, nonatomic) IBOutlet UIView *view_PhotoTagView;
@property (weak, nonatomic) IBOutlet UIView *view_PhotoFriendsView;
@property (weak, nonatomic) IBOutlet UIButton *btn_PrivacyPhoto;
@property (weak, nonatomic) IBOutlet UIView *view_Privacy;
@property (weak, nonatomic) IBOutlet UITextField *txt_hashTag;

- (IBAction)act_PostPhoto:(id)sender;
- (IBAction)act_TakePhoto:(id)sender;
- (IBAction)act_UploadPhoto:(id)sender;
- (IBAction)act_TagPhoto:(id)sender;
- (IBAction)act_Friends:(id)sender;
- (IBAction)act_ClosePhoto:(id)sender;
- (IBAction)act_HashTagDone:(id)sender;
- (IBAction)act_FriendsExceptAcq:(id)sender;
- (IBAction)act_Public:(id)sender;

@end
