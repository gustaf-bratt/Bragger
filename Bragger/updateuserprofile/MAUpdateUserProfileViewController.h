//
//  MAUpdateUserProfileViewController.h
//  Bragger
//
//  Created by vino on 06/03/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAUpdateUserProfileViewController : UIViewController<UITextFieldDelegate>
- (IBAction)act_HideKeyboard:(id)sender;
@property (weak, nonatomic) IBOutlet UITextField *nickNameTxt;
@property (weak, nonatomic) IBOutlet UITextField *emailIdTxt;
- (IBAction)act_Submit:(id)sender;
- (IBAction)act_Back:(id)sender;
@end
