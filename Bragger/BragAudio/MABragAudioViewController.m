//
//  MABragAudioViewController.m
//  Bragger
//
//  Created by GaoShen on 2/2/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)

#import "UIViewController+MJPopupViewController.h"
#import "MABraggingStreamViewController.h"
#import "MABragAudioViewController.h"
#import "MABragPhotoViewController.h"
#import "MABraggerProfileViewController.h"
#import "MADiscoverBraggerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MASingleton.h"
#import "Constant.h"

enum privacy
{
    public = 0,
    followersOnly,
};

@interface MABragAudioViewController ()
{
    NSString *userId;
    NSString *sessionId;
    NSString *str_latitude;
    NSString *str_longitude;
    AVAudioRecorder *recorder;
    NSString *letters;
    NSString *str_ReturnFileName;
    NSURL *outputFileURL;
    BOOL isTxtFieldIsEditing;
    enum privacy privacyValue;
	Reachability *reachability;
	UIAlertView *alert4Connectivity;
	BOOL isAlertShowing;

}
@end

@implementation MABragAudioViewController
int ii=0,jj=0,kk=0;
@synthesize textvw_Commenttext,view_AudioFriendsView,view_AudiTagView,view2,Audiorecorder,btn_AudioRecording,lbl_StopRecording;
@synthesize btn_Privacy;
@synthesize txt_HashTag;
#pragma mark - View Life Cycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		[self checkConnection];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    view_AudiTagView.hidden=YES;
    view_AudioFriendsView.hidden=YES;
    lbl_StopRecording.hidden = YES;
    textvw_Commenttext.textColor = [UIColor lightGrayColor];
    textvw_Commenttext.delegate=self;
    
    txt_HashTag.delegate = self;
    
    userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_id"];
    str_latitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
    str_longitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"longtitude"];
    privacyValue = 0;
    
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Audio Record and Post

// Post Audio
- (IBAction)act_AudioPost:(id)sender
{
    NSLog(@"url:%@",outputFileURL);
    NSData *data_Audio = [NSData dataWithContentsOfURL:outputFileURL];
    if (data_Audio == NULL)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bragger" message:@"Please select audio" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    
    else if ([textvw_Commenttext.text isEqualToString:@""] || [textvw_Commenttext.text isEqualToString:@"Enter your message here"] )
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bragger" message:@"Please enter title" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    else
    {
        
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        [self.view bringSubviewToFront:HUD];
        
        HUD.dimBackground = YES;
        
        // Regiser for HUD callbacks so we can remove it from the window at the right time
        HUD.delegate = self;
        
        // Show the HUD while the provided method executes in a new thread
        [HUD showWhileExecuting:@selector(postAudioTask) onTarget:self withObject:nil animated:YES];
        
    }
}

// Post Audio to Server
-(void)postAudioTask
{
    
    NSString *hashTag;
    //Update by Sabari 22/March
//    if ([txt_HashTag.text isEqual:[NSNull null]] || [txt_HashTag.text isEqual:@""])
//    {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bragger" message:@"Please tag the brag" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
//    }
//    else
//    {
        hashTag = txt_HashTag.text;
        
        NSString *str_PostTitle = textvw_Commenttext.text;
        
        NSData *data_Audio = [NSData dataWithContentsOfURL:outputFileURL];
        
        NSString *urlAsString = GETAPILINK(@"postwebs/AddPost/");
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&post_title=%@",str_PostTitle]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&mediatype=audio"]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&post_location=%@",[[MASingleton sharedManager] getLocation]]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&hash_tag=%@",hashTag]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&lat=%@",str_latitude]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&lon=%@",str_longitude]];
        switch (privacyValue)
        {
            case public:
                urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&privacy_level=public"]];
                break;
            case followersOnly:
                urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&privacy_level=friends"]];
                break;
            default:
                break;
        }
        
        NSString *properlyEscapedURL = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:properlyEscapedURL];
        
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:url];
        [request setHTTPMethod:@"POST"];
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
        [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
        
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"post_mediafile\"; filename=\"test2.mp4\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:data_Audio]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        
        NSLog(@"Request body %@", [[NSString alloc] initWithData:[request HTTPBody] encoding:NSUTF8StringEncoding]);
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        
        NSLog(@"Image Return String: %@", returnString);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bragger" message:@"Audio Posted Successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self act_CloseAudio:nil];
//    }
}

// Audio Recording
- (IBAction)act_AudioRecord:(id)sender
{
    if (kk==0)
    {
        lbl_StopRecording.hidden = NO;
        [btn_AudioRecording setImage:[UIImage imageNamed:@"audio_recordingIcon.png"] forState:UIControlStateNormal];
        letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        
        [self genRandStringLength:8];
        
        NSString *str_FileName = [NSString stringWithFormat:@"%@.m4a",str_ReturnFileName];
        
        // Set the audio file
        NSArray *pathComponents = [NSArray arrayWithObjects:
                                   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject],
                                   str_FileName,
                                   nil];
        outputFileURL = [NSURL fileURLWithPathComponents:pathComponents];
        
        
        // Setup audio session
        AVAudioSession *session = [AVAudioSession sharedInstance];
        [session setCategory:AVAudioSessionCategoryRecord error:nil];
        
        // Define the recorder setting
        NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
        
        [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
        [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
        [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
        
        // Initiate and prepare the recorder
        recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:nil];
        recorder.delegate = self;
        recorder.meteringEnabled = YES;
        [recorder prepareToRecord];
        
        [session setActive:YES error:nil];
        
        // Start recording
        [recorder record];
        
        kk++;
    }
    else
    {
        lbl_StopRecording.hidden=YES;
        [btn_AudioRecording setImage:[UIImage imageNamed:@"audio_Icon.png"] forState:UIControlStateNormal];
        [recorder stop];
        
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
        
        kk--;
    }
    
    NSLog(@"OutputFile Url : %@",outputFileURL);
    
}

-(NSString *) genRandStringLength: (int) len
{
    
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    
    str_ReturnFileName = randomString;
    
    return randomString;
}

#pragma mark - Close, Privacy, Tag

// For Close the current View Controller
- (IBAction)act_CloseAudio:(id)sender
{
    if (view2==0)
    {
		MABraggingStreamViewController *obj_AboutVC;
        obj_AboutVC = [[MABraggingStreamViewController alloc] initWithNibName:@"MABraggingStreamViewController" bundle:nil];
		[self presentViewController:obj_AboutVC animated:YES completion:nil];
	}
	else if(view2==1)
        
    {
        MADiscoverBraggerViewController *obj_AboutVC;
		obj_AboutVC = [[MADiscoverBraggerViewController alloc] initWithNibName:@"MADiscoverBraggerViewController" bundle:nil];
		[self presentViewController:obj_AboutVC animated:YES completion:nil];
    }
    else
    {
        MABraggerProfileViewController *obj_AboutVC;
        obj_AboutVC = [[MABraggerProfileViewController alloc] initWithNibName:@"MABraggerProfileViewController" bundle:nil];
		[self presentViewController:obj_AboutVC animated:YES completion:nil];
	}
    
}

// For Set the Friends PrivacyLevels
- (IBAction)act_FriendsAudio:(id)sender
{
    
    if (ii==0) {
        
        
        view_AudioFriendsView.hidden= NO;
        
        ii++;
    }
    else
    {
        view_AudioFriendsView.hidden=YES;
        
        ii--;
    }
    
}

// For Setting the Tag
- (IBAction)act_AudioTag:(id)sender
{
    if (jj==0)
    {
        view_AudiTagView.hidden= NO;
        jj++;
    }
    else
    {
        view_AudiTagView.hidden=YES;
        jj--;
    }
}

#pragma mark - TextView Delegate
// For TextView animation and Delegates
- (void) animateTextView:(BOOL) up
{
    const int movementDistance =120.0; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    int movement= movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if([text isEqualToString:@"\n"])
    {
        [textvw_Commenttext resignFirstResponder];
        return NO;
    }
    return YES;
    
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    if(textvw_Commenttext.text.length == 0)
    {
        textvw_Commenttext.textColor = [UIColor lightGrayColor];
        [textvw_Commenttext resignFirstResponder];
    }
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textvw_Commenttext.text isEqual:@"Enter your message here"])
        textvw_Commenttext.text = @"";
    textvw_Commenttext.textColor = [UIColor blackColor];
    if (isTxtFieldIsEditing != YES)
    {
        [self animateTextView : YES];
    }
    
    return YES;
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self animateTextView:NO];
    return YES;
}

-(BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    isTxtFieldIsEditing = YES;
    [self animateTextView:YES];
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField*)textField
{
    isTxtFieldIsEditing = NO;
    [self animateTextView:NO];
    
    [textField resignFirstResponder];
    return YES;
}


- (IBAction)nextBtn:(id)sender
{
    MABragPhotoViewController *obj_AboutVC;
    obj_AboutVC = [[MABragPhotoViewController alloc] initWithNibName:@"MABragPhotoViewController" bundle:nil];
    
    [self presentViewController:obj_AboutVC animated:YES completion:nil];
}

// Selecting Public from Friends PrivacyLevel
- (IBAction)act_Public:(id)sender
{
    
    privacyValue = public;
    [self act_FriendsAudio:nil];
    [btn_Privacy setBackgroundImage:[UIImage imageNamed:@"public_List.png"]  forState:UIControlStateNormal];
    btn_Privacy.frame = CGRectMake(btn_Privacy.frame.origin.x, btn_Privacy.frame.origin.y, 79, btn_Privacy.frame.size.height);
}

// Selecting FriendsExceptAcquaintances from Friends PrivacyLevel
- (IBAction)act_FrndsdEcptAcq:(id)sender
{
    
    privacyValue = followersOnly;
    [self act_FriendsAudio:nil];
    [btn_Privacy setBackgroundImage:[UIImage imageNamed:@"Friends_except_Acquaintances_List.png"]  forState:UIControlStateNormal];
    
    btn_Privacy.frame = CGRectMake(btn_Privacy.frame.origin.x, btn_Privacy.frame.origin.y, btn_Privacy.frame.size.width * 1.5, btn_Privacy.frame.size.height);
}

// For set the HashTag option
- (IBAction)act_HashTagDone:(id)sender
{
    
    [self act_AudioTag:nil];
    
}



#pragma mark - Internet Connection
- (void)checkConnection
{
	
	
	reachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
	
    // Start Monitori
    [reachability startNotifier];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
	
}


- (void)reachabilityDidChange:(NSNotification *)notification
{
	
	
	Reachability* curReach = [notification object];
	NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
	[self updateInterfaceWithReachability:curReach];

	
	
}



-(void)updateInterfaceWithReachability:(Reachability*)locReachability
{
	
	NetworkStatus netStatus = [locReachability currentReachabilityStatus];
	
	
    if (netStatus == NotReachable)
	{
		if (!alert4Connectivity.visible)
		{
			alert4Connectivity = [[UIAlertView alloc] initWithTitle:@"Bragger" message:@"Yikes! You don’t have internet connection! How will you brag about stuff? Once you are back online, then come back to the app" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			[alert4Connectivity show];
			isAlertShowing = YES;
			
		}
	}
	
    
	else
	{
		NSLog(@"Reachable");
		isAlertShowing = NO;
		
		
	}

}


@end
