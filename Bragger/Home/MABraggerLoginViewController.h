//
//  MABraggerLoginViewController.h
//  Bragger
//
//  Created by GaoShen on 2/2/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MABraggerLoginViewController.h"
#import <GooglePlus/GooglePlus.h>

@class GPPSignInButton;
@interface MABraggerLoginViewController : UIViewController<GPPSignInDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *img_BraggerHomePage;
- (IBAction)act_Facebook:(id)sender;
- (IBAction)act_GooglePlus:(id)sender;
- (IBAction)act_SignUpEmail:(id)sender;
- (IBAction)act_BragAnonymously:(id)sender;
- (IBAction)act_Login:(id)sender;
- (IBAction)act_twitter:(id)sender;

+(BOOL)isBragAnnIsSelected;

@end
