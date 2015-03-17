//
//  MAChangePwdViewController.h
//  Bragger
//
//  Created by vino on 05/03/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAChangePwdViewController : UIViewController<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nwPassTxt;
@property (weak, nonatomic) IBOutlet UITextField *conPassTxt;
@property (weak, nonatomic) IBOutlet UITextField *oldPassTxt;

- (IBAction)act_HideKeyboard:(id)sender;
- (IBAction)act_submit:(id)sender;
- (IBAction)act_Back:(id)sender;

@end
