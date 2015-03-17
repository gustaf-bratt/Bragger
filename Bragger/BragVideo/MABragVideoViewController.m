//
//  MABragVideoViewController.m
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
#import "MABraggerProfileViewController.h"
#import "MADiscoverBraggerViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "MABragVideoViewController.h"
#import "MABraggingStreamViewController.h"
#import "MABragWriteViewController.h"
#import "MASingleton.h"
#import "Constant.h"

enum privacy
{
    public = 0,
    followersOnly,
};

@interface MABragVideoViewController ()
{
    NSString *userId;
    NSString *sessionId;
    NSString *str_latitude;
    NSString *str_longitude;
    enum privacy privacyValue;
    BOOL isTextFieldIsEditing;
	Reachability *reachability;
	UIAlertView *alert4Connectivity;
	BOOL isAlertShowing;

}
@end

int tag=0;
int friend=0;

@implementation MABragVideoViewController
@synthesize txtvw_COmmentTextView,view2,movieURL,movieController,view_VideoFriendsView,view_VideoTagView;
@synthesize btn_Privacy;
@synthesize txt_HashTag;

#pragma mark - View Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
		
    }
    return self;
}
-(void) viewWillAppear:(BOOL)animated
{
	[self checkConnection];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
}
-(void) viewWillDisappear:(BOOL)animated
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    txtvw_COmmentTextView.textColor = [UIColor lightGrayColor];
    view_VideoFriendsView.hidden=YES;
    view_VideoTagView.hidden=YES;
    txt_HashTag.delegate = self;
    txtvw_COmmentTextView.delegate=self;
    userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_id"];
    str_latitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
    str_longitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"longtitude"];
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Take, Choose, Post
// Post Video
- (IBAction)act_PostVideo:(id)sender
{
	NSData *data_Audio = [NSData dataWithContentsOfURL:movieURL];

	if ([txtvw_COmmentTextView.text isEqualToString:@""] || [txtvw_COmmentTextView.text isEqualToString:@"Enter your message here"])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bragger" message:@"Please enter title" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
	}
	else  if (data_Audio == NULL)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bragger" message:@"Please select video" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
    [HUD showWhileExecuting:@selector(postVideoTask) onTarget:self withObject:nil animated:YES];
	}
}

// Post video to Server
-(void)postVideoTask
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
        NSString *str_PostTitle = txtvw_COmmentTextView.text;
        NSData *data_PostingVideo = [NSData dataWithContentsOfURL:movieURL];
	
	
	    UIImage *thumbImg = [self loadImage:movieURL];
	     NSData *data_PostingImage = UIImageJPEGRepresentation(thumbImg, 1.0);
	
        NSString *urlAsString = GETAPILINK(@"postwebs/AddPost/");
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&post_title=%@",str_PostTitle]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&mediatype=video"]];
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
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"post_mediafile\"; filename=\"video.mov\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:data_PostingVideo]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
//        [request setHTTPBody:body];
	
	
	
//	NSString *boundary2 = @"---------------------------14737809831466499882756415616525361";
//	NSString *contentType2 = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary2];
//	[request addValue:contentType2 forHTTPHeaderField: @"Content-Type"];
//
//		NSMutableData *body2 = [NSMutableData data];
		[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"media_type_file\"; filename=\"test2.png\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[NSData dataWithData:data_PostingImage]];
		[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
		[request setHTTPBody:body];

	
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        NSLog(@"Image Return String: %@", returnString);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bragger" message:@"Video Posted Successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        [self act_CloseVideo:nil];
//	}
}

// Take new Video From device.
- (IBAction)act_TakeVideo:(id)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie, nil];
    
    [self presentViewController:picker animated:YES completion:NULL];
}

// Pick Video From device Photo Library.
- (IBAction)act_UploadVideo:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie,      nil];
    [self presentViewController:imagePicker animated:YES completion:NULL];
    
}

// Image Picker Delegates
#pragma mark - Image Picker Controller
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo)
    {
//        NSString *moviePath = [[info objectForKey:UIImagePickerControllerMediaURL] path];
        movieURL=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        
//        if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum (moviePath))
//        {
//            UISaveVideoAtPathToSavedPhotosAlbum (moviePath, nil, nil, nil);
//        }
    }
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

- (void)moviePlayBackDidFinish:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    [self.movieController stop];
    [self.movieController.view removeFromSuperview];
    self.movieController = nil;
}

#pragma mark - Tag, Friends
// For Setting the Tag
- (IBAction)act_Tag:(id)sender
{
    if (tag==0)
    {
        view_VideoTagView.hidden= NO;
        tag++;
    }
    else
    {
        view_VideoTagView.hidden=YES;
        tag--;
    }
}

// For Set the Friends PrivacyLevels
- (IBAction)act_Friends:(id)sender
{
    if (friend==0)
    {
        view_VideoFriendsView.hidden= NO;
        friend++;
    }
    else
    {
        view_VideoFriendsView.hidden=YES;
        friend--;
    }
}


#pragma mark - Close
// For Close the current View Controller
- (IBAction)act_CloseVideo:(id)sender
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

#pragma mark - TextView Delegate
// For TextView animation and Delegates
- (void) animateTextView:(BOOL) up
{
    const int movementDistance =120.0;
    const float movementDuration = 0.3f;
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
        [txtvw_COmmentTextView resignFirstResponder];
        return NO;
    }
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    if(txtvw_COmmentTextView .text.length == 0)
    {
        txtvw_COmmentTextView .textColor = [UIColor lightGrayColor];
        [txtvw_COmmentTextView  resignFirstResponder];
    }
}
- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if ([txtvw_COmmentTextView.text isEqual:@"Enter your message here"])
        txtvw_COmmentTextView.text = @"";
    txtvw_COmmentTextView .textColor = [UIColor blackColor];
    if (isTextFieldIsEditing != YES)
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
    isTextFieldIsEditing = YES;
    [self animateTextView:YES];
    return YES;
}

- (BOOL) textFieldShouldReturn:(UITextField*)textField
{
    isTextFieldIsEditing = NO;
    [self animateTextView:NO];
    
    [textField resignFirstResponder];
    return YES;
}

// Selecting Public from Friends PrivacyLevel
- (IBAction)act_Public:(id)sender
{
    privacyValue = public;
    [self act_Friends:nil];
    [btn_Privacy setBackgroundImage:[UIImage imageNamed:@"public_List.png"]  forState:UIControlStateNormal];
    btn_Privacy.frame = CGRectMake(btn_Privacy.frame.origin.x, btn_Privacy.frame.origin.y, 79, btn_Privacy.frame.size.height);
    
}

// Selecting FriendsExceptAcquaintances from Friends PrivacyLevel
- (IBAction)act_FriendsExceptAcq:(id)sender
{
    privacyValue = followersOnly;
    [self act_Friends:nil];
    [btn_Privacy setBackgroundImage:[UIImage imageNamed:@"Friends_except_Acquaintances_List.png"]  forState:UIControlStateNormal];
    btn_Privacy.frame = CGRectMake(btn_Privacy.frame.origin.x, btn_Privacy.frame.origin.y, btn_Privacy.frame.size.width * 1.5, btn_Privacy.frame.size.height);
}

// For set the HashTag option
- (IBAction)act_hashTagDone:(id)sender
{
    [self act_Tag:nil];
}


#pragma mark - Internet Connection
- (void)checkConnection
{

	
	reachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
	
   
    [reachability startNotifier];
	
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




- (UIImage*)loadImage:(NSURL *)vidURL
{
	
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:vidURL options:nil];
    AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
	generate.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
	
    return [[UIImage alloc] initWithCGImage:imgRef];
	
}


@end
