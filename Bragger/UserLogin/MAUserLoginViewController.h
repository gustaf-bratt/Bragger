//
//  MAExuserLoginViewController.h
//  Bragger
//
//  Created by GaoShen on 2/7/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAUserLoginViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txt_EmailTxtExUser;
@property (weak, nonatomic) IBOutlet UITextField *txt_PasswordExUser;

- (IBAction)act_Login:(id)sender;
- (IBAction)act_HideKeyboard:(id)sender;
- (IBAction)act_Forget:(id)sender;
- (IBAction)act_Back:(id)sender;
@end
