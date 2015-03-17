//
//  MABragAudioViewController.h
//  Bragger
//
//  Created by GaoShen on 2/2/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MBProgressHUD.h"
@interface MABragAudioViewController : UIViewController<UITextViewDelegate,AVAudioRecorderDelegate,MBProgressHUDDelegate,UITextFieldDelegate>
{
 MBProgressHUD *HUD;
}

@property (nonatomic, strong) AVAudioRecorder *Audiorecorder;
@property(assign) unsigned int view2;
@property (weak, nonatomic) IBOutlet UITextView *textvw_Commenttext;
@property (weak, nonatomic) IBOutlet UIView *view_AudiTagView;
@property (weak, nonatomic) IBOutlet UIView *view_AudioFriendsView;
@property (weak, nonatomic) IBOutlet UIButton *btn_AudioRecording;
@property (weak, nonatomic) IBOutlet UILabel *lbl_StopRecording;
@property (weak, nonatomic) IBOutlet UIButton *btn_Privacy;
@property (weak, nonatomic) IBOutlet UITextField *txt_HashTag;

- (IBAction)act_AudioPost:(id)sender;
- (IBAction)act_CloseAudio:(id)sender;
- (IBAction)act_AudioRecord:(id)sender;
- (IBAction)act_FriendsAudio:(id)sender;
- (IBAction)act_AudioTag:(id)sender;
- (IBAction)act_Public:(id)sender;
- (IBAction)act_FrndsdEcptAcq:(id)sender;
-(NSString *)genRandStringLength: (int) len;
@end
