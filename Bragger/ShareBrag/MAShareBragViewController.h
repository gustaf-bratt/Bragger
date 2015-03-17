//
//  MAShareBragViewController.h
//  Bragger
//
//  Created by GaoShen on 2/5/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MAShareBragViewController : UIViewController

@property (assign) BOOL myProperty1;
@property(assign) unsigned int view1;
@property(strong,nonatomic) NSDictionary *BragUserDetails2;

- (IBAction)act_BragAudio:(id)sender;
- (IBAction)act_BragPhoto:(id)sender;
- (IBAction)act_BragVideo:(id)sender;
- (IBAction)act_BragWrite:(id)sender;
- (IBAction)act_close:(id)sender;

@end
