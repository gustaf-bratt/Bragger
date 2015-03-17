//
//  MASignUpEmailViewController.h
//  Bragger
//
//  Created by GaoShen on 2/2/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
@interface MASignUpEmailViewController : UIViewController<UITextFieldDelegate,UITabBarControllerDelegate,CLLocationManagerDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
  UIImagePickerController *picker;
}
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UITabBarController *tabBarController;
@property (weak, nonatomic) IBOutlet UITextField *emailTxt;
@property (weak, nonatomic) IBOutlet UITextField *realNameTxt;
@property (weak, nonatomic) IBOutlet UITextField *nickNameTxt;
@property (weak, nonatomic) IBOutlet UITextField *confirmPasswordTxt;
@property (weak, nonatomic) IBOutlet UITextField *passwordTxt;
@property (strong,nonatomic)IBOutlet UIButton *btn_ProfilePicture;
@property (weak, nonatomic) IBOutlet UIWebView *TermsAndConditionWebVw;
@property (weak, nonatomic) IBOutlet UIButton *closeWebVwBtn;
@property (strong,nonatomic)NSString *realNameStr;
@property (strong,nonatomic)NSString *emailStr;
@property (strong,nonatomic)NSString *pictureStr;
@property(strong,nonatomic) NSDictionary *deserializedDictionary;
@property (nonatomic) BOOL isFromFB;
@property (nonatomic) BOOL isFromTwitter;
@property (nonatomic) BOOL isFromGoogle;
@property (assign) BOOL istickclicked;

- (IBAction)act_SignUpBtn:(id)sender;
- (IBAction)act_UserProfileImage:(id)sender;
- (IBAction)act_BackButton:(id)sender;
- (IBAction)act_CloseTermsAndConditions:(id)sender;
- (IBAction)act_OpenTermsAndConditions:(id)sender;
- (IBAction)act_HideKeyboard:(id)sender;
- (IBAction)act_TickBtn:(id)sender;

@end
