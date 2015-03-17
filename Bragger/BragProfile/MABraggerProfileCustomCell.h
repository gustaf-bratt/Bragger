//
//  MABraggerProfileCustomCell.h
//  Bragger
//
//  Created by Muthu Sabari on 2/14/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MABraggerProfileCustomCell : UITableViewCell<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *img_FromPostMediaFile;
@property (weak, nonatomic) IBOutlet UIButton *btn_Comment;
@property (weak, nonatomic) IBOutlet UIButton *btn_ShowOff;
@property (weak, nonatomic) IBOutlet UIButton *btn_PostLike;
@property (weak, nonatomic) IBOutlet UITextField *txt_CommentBragText;
@property (weak, nonatomic) IBOutlet UILabel *totalLike4PostLbl;
@property (weak, nonatomic) IBOutlet UILabel *totalShowOff4PostLbl;
@property (weak, nonatomic) IBOutlet UILabel *totalReBrags4PostLbl;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLbl;
@property (weak, nonatomic) IBOutlet UIButton *btnReBrag;
@property (weak, nonatomic) IBOutlet UIButton *btnLIkeVw;
@property (weak, nonatomic) IBOutlet UIButton *btnRebragVw;
@property (weak, nonatomic) IBOutlet UIButton *btnShowOffVw;
@property (weak, nonatomic) IBOutlet UILabel *hashTag;
@property (weak, nonatomic) IBOutlet UIButton *mediaBtn;

+(NSString*)reuseIdentifier;
-(IBAction)HdKeyboard:(id)sender;
@end
