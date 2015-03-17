//
//  MABraggingStreamCustomCell.h
//  Bragger
//
//  Created by Muthu Sabari on 2/13/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MABraggingStreamCustomCell : UITableViewCell<UITextFieldDelegate>

@property (nonatomic) UILabel *lbl_TotalLike4Post;
@property (nonatomic) UILabel *lbl_TotalShowOff4Post;
@property (nonatomic) UILabel *lbl_TotalReBrags4Post;
@property (nonatomic) UIButton *btn_BraggerName;
@property (nonatomic) UILabel *lbl_LocationLabel;
@property (nonatomic) UILabel *lbl_TitleLabel;
@property (nonatomic) UITextField *txt_CommentBragText;
@property (nonatomic) UIButton *btn_PostLike;
@property (nonatomic) UIButton *btn_Follower;
@property (nonatomic) UIButton *btn_ShowOff;
@property (nonatomic) UIButton *btn_Comment;
@property (nonatomic) UIImageView *img_ToUserImage;
@property (nonatomic) UIImageView *img_FromPostMediaFile;
@property (nonatomic) UIButton *btn_imgFromPostMediaFile;
@property (nonatomic) UILabel *lbl_PostTime;
@property (nonatomic) UIButton *btn_LikeInVw;
@property (nonatomic) UIButton *btn_ShowOffVw;
@property (nonatomic) UIButton *btn_RebragVw;
@property (nonatomic) UIButton *btn_Rebrag;
@property (nonatomic) UILabel *lbl_HashTag;
@property (nonatomic) UILabel *lbl_WritePost;
@property (nonatomic) UIImageView *img_PinLocation;
@property (nonatomic) UIButton *btn_Flag;
-(IBAction)HdKeyboard:(id)sender;
+(NSString*)reuseIdentifier;

@end
