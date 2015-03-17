//
//  MABragWriteViewController.m
//  Bragger
//
//  Created by GaoShen on 2/3/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)
#import "MABraggerProfileViewController.h"
#import "MADiscoverBraggerViewController.h"
#import "MABraggingStreamViewController.h"
#import "MABragWriteViewController.h"
#import "MABraggingStreamViewController.h"

#import "UIViewController+MJPopupViewController.h"
#import "Reachability.h"
#import "MASingleton.h"
#import "Constant.h"

enum privacy
{
    public = 0,
    followersOnly
};

@interface MABragWriteViewController ()
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
int i=0,j=0;
@implementation MABragWriteViewController
@synthesize txtvew_CommentTextview,view_CLickTAgBtnView,view_FriendsDropDownVIew,view2,deserializedDictionary;
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
	isAlertShowing = NO;
    view_CLickTAgBtnView.hidden=YES;
    view_FriendsDropDownVIew.hidden=YES;
    // txtvew_CommentTextview.text = @"Enter your message here...";
    txtvew_CommentTextview.textColor = [UIColor lightGrayColor];
    txtvew_CommentTextview.delegate=self;
    txt_HashTag.delegate = self;
    // Do any additional setup after loading the view from its nib.
    userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_id"];
    str_latitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
    str_longitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"longtitude"];
    
}

#pragma mark - Post Text

// Post Write
- (IBAction)act_PostText:(id)sender
{
   
	if ([txtvew_CommentTextview.text isEqualToString:@"Enter your message here"] ||  [txtvew_CommentTextview.text isEqualToString:@""])
	{
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bragger" message:@"Please Enter the Text" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		       [alert show];

	}
	else
	{
	NSString *str_PostText = txtvew_CommentTextview.text;
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
        NSString *urlAsString = GETAPILINK(@"postwebs/PostText/");
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?post_title=%@",str_PostText]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user_id=%@",userId]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&mediatype=text"]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&hash_tag=%@",hashTag]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&lat=%@",str_latitude]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&lon=%@",str_longitude]];
//	    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&post_location=%@",[[MASingleton sharedManager] getLocation]]];
    
        
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
        
        NSLog(@"URL : %@",urlAsString);
        
        NSString *properlyEscapedURL = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *url = [NSURL URLWithString:properlyEscapedURL];
        
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        
        [urlRequest setTimeoutInterval:30.0f];
        [urlRequest setHTTPMethod:@"POST"];
        NSURLResponse *response = nil;
        NSError *error = nil;
        NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest
                                             returningResponse:&response error:&error];
        
        if ([data length] >0  && error == nil)
        {
            
            error = nil;
            id jsonObject = [NSJSONSerialization
                             JSONObjectWithData:data
                             options:NSJSONReadingAllowFragments
                             error:&error];
            if (jsonObject != nil && error == nil)
            {
                NSLog(@"Successfully deserialized...");
                if ([jsonObject isKindOfClass:[NSDictionary class]])
                {
                    
                    if ([[deserializedDictionary objectForKey:@"jsonstatus" ] isEqualToString:@"fail"])
                    {
                        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message: (NSString*)[deserializedDictionary objectForKey:@"message"]
                                                                              delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                        
                        [alertsuccess show];
                    }
                    [self act_Close:nil];
                }
            }
            
        }
//    }
	}
    
}


// For set the HashTag option
- (IBAction)act_HashTagDone:(id)sender
{
    [self act_ClickTag:nil];
}

// Selecting Public from Friends PrivacyLevel
- (IBAction)act_Public:(id)sender
{
    privacyValue = public;
    [self act_FriendsDrop:nil];
    [btn_Privacy setBackgroundImage:[UIImage imageNamed:@"public_List.png"]  forState:UIControlStateNormal];
    btn_Privacy.frame = CGRectMake(btn_Privacy.frame.origin.x, btn_Privacy.frame.origin.y, 79, btn_Privacy.frame.size.height);
}

// Selecting FriendsExceptAcquaintances from Friends PrivacyLevel
- (IBAction)act_friendsExceptAcq:(id)sender
{
    privacyValue = followersOnly;
    [self act_FriendsDrop:nil];
    [btn_Privacy setBackgroundImage:[UIImage imageNamed:@"Friends_except_Acquaintances_List.png"]  forState:UIControlStateNormal];
    
    btn_Privacy.frame = CGRectMake(btn_Privacy.frame.origin.x, btn_Privacy.frame.origin.y, btn_Privacy.frame.size.width * 1.5, btn_Privacy.frame.size.height);
}

#pragma mark - TextView Delegate
// TextView Delegates
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    
    if([text isEqualToString:@"\n"] )
    {
        [txtvew_CommentTextview resignFirstResponder];
        //        [self animateTextView : NO];
        return NO;
    }
    return YES;
}

-(void) textViewDidChange:(UITextView *)textView
{
    
    if(txtvew_CommentTextview.text.length == 0)
    {
        txtvew_CommentTextview.textColor = [UIColor lightGrayColor];
        //  textvw_Commenttext.text = @"Enter your message here...";
        
        [txtvew_CommentTextview resignFirstResponder];
    }
    
}

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if ([txtvew_CommentTextview.text isEqual:@"Enter your message here"])
        txtvew_CommentTextview.text = @"";
    
    txtvew_CommentTextview.textColor = [UIColor blackColor];
    if (isTextFieldIsEditing != YES)
        [self animateTextView : YES];
    
    return YES;
    
}

-(BOOL)textViewShouldEndEditing:(UITextView *)textView
{
    
    [self animateTextView:NO];
    return YES;
    
}

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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    isTextFieldIsEditing = YES;
    [self animateTextView : YES];
    
}
- (BOOL) textFieldShouldReturn:(UITextField*)textField
{
    isTextFieldIsEditing = NO;
    [self animateTextView:NO];
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Next, Close,

// For Close the current View Controller
- (IBAction)act_Close:(id)sender
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

// For Setting the Tag
- (IBAction)act_ClickTag:(id)sender
{
    
    if (i==0) {
        view_CLickTAgBtnView.hidden= NO;
        i++;
    }
    else
    {
        view_CLickTAgBtnView.hidden=YES;
        i--;
    }
    
}

// For Set the Friends PrivacyLevels
- (IBAction)act_FriendsDrop:(id)sender
{
    
    if (j==0)
    {
        view_FriendsDropDownVIew.hidden= NO;
        j++;
    }
    else
    {
        view_FriendsDropDownVIew.hidden=YES;
        j--;
    }
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
