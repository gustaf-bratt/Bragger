//
//  MASettingsViewController.h
//  Bragger
//
//  Created by vino on 05/03/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MAChangePwdViewController.h"
#import "MBProgressHUD.h"
@interface MASettingsViewController : UIViewController<UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,MBProgressHUDDelegate>
{
	UIImagePickerController *picker;
	MBProgressHUD *HUD;
}
- (IBAction)act_LogOut:(id)sender;
- (IBAction)act_ChangePassword:(id)sender;
- (IBAction)act_Back:(id)sender;
- (IBAction)act_ChangeProfilePic:(id)sender;
- (IBAction)act_UpdateUserProfile:(id)sender;

@end
