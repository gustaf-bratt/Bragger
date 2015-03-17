//
//  MABragWriteViewController.h
//  Bragger
//
//  Created by GaoShen on 2/3/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MABragWriteViewController : UIViewController<UITextViewDelegate,UITextFieldDelegate>

@property(assign) unsigned int view2;
@property(strong,nonatomic) NSDictionary *deserializedDictionary;
@property (weak, nonatomic) IBOutlet UITextView *txtvew_CommentTextview;
@property (weak, nonatomic) IBOutlet UIView *view_CLickTAgBtnView;
@property (weak, nonatomic) IBOutlet UIView *view_FriendsDropDownVIew;
@property (weak, nonatomic) IBOutlet UIButton *btn_Privacy;
@property (weak, nonatomic) IBOutlet UITextField *txt_HashTag;

- (IBAction)act_Close:(id)sender;
- (IBAction)act_ClickTag:(id)sender;
- (IBAction)act_FriendsDrop:(id)sender;
- (IBAction)act_PostText:(id)sender;
- (IBAction)act_HashTagDone:(id)sender;
- (IBAction)act_Public:(id)sender;
- (IBAction)act_friendsExceptAcq:(id)sender;
@end
