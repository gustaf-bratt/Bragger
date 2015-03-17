//
//  MABragPhotoViewController.m
//  Bragger
//
//  Created by GaoShen on 2/2/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)
#import "MABraggingStreamViewController.h"
#import "MABragPhotoViewController.h"
#import "MABragVideoViewController.h"
#import "MABraggerProfileViewController.h"
#import "MADiscoverBraggerViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "MASingleton.h"
#import "Constant.h"

enum privacy
{
    public = 0,
    followersOnly,
};

@interface MABragPhotoViewController ()
{
    UIImagePickerController *img_PickerController;
    NSString *userId;
    NSString *sessionId;
    NSString *str_latitude;
    NSString *str_longitude;
    BOOL selectPhoto;
    enum privacy privacyValue;
    BOOL isTextFieldIsEditing;
    
    BOOL isPrivacyViewOpen;
	Reachability *reachability;
	UIAlertView *alert4Connectivity;
	BOOL isAlertShowing;
}
@end

int tagphoto=0;
int friendsphoto=0;

@implementation MABragPhotoViewController
@synthesize txtView_Comment,view2,img_Choosed,str_UserID,str_SessionID,BragUserDetails2,view_PhotoFriendsView,view_PhotoTagView;
@synthesize btn_PrivacyPhoto;
@synthesize view_Privacy;
@synthesize txt_hashTag;

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
{    [super viewDidLoad];
	
    view_Privacy.hidden = NO;
    isPrivacyViewOpen = NO;
    // txtView_Comment.text = @"Enter your message here...";
    txtView_Comment.textColor = [UIColor lightGrayColor];
    txtView_Comment.delegate = self;
    txt_hashTag.delegate = self;
    view_PhotoFriendsView.hidden=YES;
    view_PhotoTagView.hidden=YES;
    userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_id"];
    str_latitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
    str_longitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"longtitude"];
    
    img_Choosed.hidden = YES;
    
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIAlertView *myAlertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                                              message:@"Device has no camera"
                                                             delegate:nil
                                                    cancelButtonTitle:@"OK"
                                                    otherButtonTitles: nil];
        
        [myAlertView show];
        
    }
    // Do any additional setup after loading the view from its nib.
    privacyValue = 0;
    selectPhoto = NO;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Take, upload & post

// Post Photo
- (IBAction)act_PostPhoto:(id)sender
{
    CGImageRef cgref = [img_Choosed.image CGImage];
    CIImage *cim = [img_Choosed.image CIImage];
    
    if (cim == nil && cgref == NULL)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bragger" message:@"Please select image" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        
    }
    else if ([txtView_Comment.text isEqualToString:@""] || [txtView_Comment.text isEqualToString:@"Enter your caption..."])
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bragger" message:@"Please enter a caption..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
        [HUD showWhileExecuting:@selector(postPhotoTask) onTarget:self withObject:nil animated:YES];
    }
}

// Post Photo To a Server
- (void)postPhotoTask
{
    
    NSString *hashTag;
    //Update by Sabari 22/March
//    if ([txt_hashTag.text isEqual:[NSNull null]] || [txt_hashTag.text isEqual:@""])
//    {
////        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bragger" message:@"Please tag the brag" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
////        [alert show];
//        hashTag = @" ";
//    }
//    else
//    {
        hashTag = txt_hashTag.text;
        
        
        NSString *str_PostTitle = txtView_Comment.text;
        
        UIImage *img_Posting = img_Choosed.image;
        NSData *data_PostingImage = UIImageJPEGRepresentation(img_Posting, 1.0);
        NSLog(@"%u KB",(data_PostingImage.length/1024));
    
        img_Choosed.hidden = YES;
        
        NSString *urlAsString = GETAPILINK(@"postwebs/AddPost/");
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];//,str_UserID]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];//str_SessionID]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&post_title=%@",str_PostTitle]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&mediatype=photo"]];
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
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"post_mediafile\"; filename=\"test2.png\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[NSData dataWithData:data_PostingImage]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        
        NSLog(@"Image Return String: %@", returnString);
    
    /*    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bragger" message:@"Image Posted Successfully" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    */
	[self act_ClosePhoto:nil];
//    }
}

// Take new Photo From device.
- (IBAction)act_TakePhoto:(UIButton *)sender
{
    selectPhoto = YES;
    img_Choosed.hidden = NO;
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:NULL];
}

// Pick Photo From device Photo Library.
- (IBAction)act_UploadPhoto:(UIButton *)sender
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    
    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma mark - Image Picker Delegate

// Image Picker Delegates
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)editingInfo
{
    UIImage *chosenImage = editingInfo[UIImagePickerControllerEditedImage];
    img_Choosed.image = chosenImage;
    img_Choosed.hidden = NO;
    
    [picker dismissViewControllerAnimated:YES completion:NULL];
    
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Tag, Friends, HashTag, Close

// For Setting the Tag
- (IBAction)act_TagPhoto:(id)sender
{
    if (tagphoto==0)
    {
        view_PhotoTagView.hidden= NO;
        
        tagphoto++;
    }
    else
    {
        view_PhotoTagView.hidden=YES;
        
        tagphoto--;
    }
}

// For Set the Friends PrivacyLevels
- (IBAction)act_Friends:(id)sender
{
    if (friendsphoto==0)
    {
        view_PhotoFriendsView.hidden= NO;
        
        friendsphoto++;
    }
    else
    {
        view_PhotoFriendsView.hidden=YES;
        
        friendsphoto--;
    }
}

// For Close the current View Controller
- (IBAction)act_ClosePhoto:(id)sender
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

// For set the HashTag option
- (IBAction)act_HashTagDone:(id)sender
{
    [self act_TagPhoto:nil];
    
}

#pragma mark - TextView Delegate
// For TextView animation and Delegates
- (void)animateTextView:(BOOL) up
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
        [txtView_Comment resignFirstResponder];
        //        [self animateTextView : NO];
        return NO;
    }
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView
{
    
    if(txtView_Comment .text.length == 0){
        txtView_Comment .textColor = [UIColor lightGrayColor];
        //  textvw_Commenttext.text = @"Enter your message here...";
        
        [txtView_Comment  resignFirstResponder];
    }
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    
    if ([txtView_Comment.text isEqual:@"Enter your caption..."])
        txtView_Comment.text = @"";
    
    txtView_Comment.textColor = [UIColor blackColor];
    if (isTextFieldIsEditing != YES)
    {
        [self animateTextView : YES];
    }
    
    return YES;
}

- (BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    [self animateTextView:NO];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
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


// Selecting FriendsExceptAcquaintances from Friends PrivacyLevel
- (IBAction)act_FriendsExceptAcq:(id)sender
{
    privacyValue = followersOnly;
    [self act_Friends:nil];
    [btn_PrivacyPhoto setBackgroundImage:[UIImage imageNamed:@"Friends_except_Acquaintances_List.png"]  forState:UIControlStateNormal];
    
    btn_PrivacyPhoto.frame = CGRectMake(btn_PrivacyPhoto.frame.origin.x, btn_PrivacyPhoto.frame.origin.y, btn_PrivacyPhoto.frame.size.width * 1.5, btn_PrivacyPhoto.frame.size.height);
}

// Selecting Public from Friends PrivacyLevel
- (IBAction)act_Public:(id)sender
{
    privacyValue = public;
    [self act_Friends:nil];
    [btn_PrivacyPhoto setBackgroundImage:[UIImage imageNamed:@"public_List.png"]  forState:UIControlStateNormal];
    btn_PrivacyPhoto.frame = CGRectMake(btn_PrivacyPhoto.frame.origin.x, btn_PrivacyPhoto.frame.origin.y, 79, btn_PrivacyPhoto.frame.size.height);
    
}



#pragma mark - Internet Connection
- (void)checkConnection
{
	
	
	reachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
	
    // Start Monitori
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



@end
