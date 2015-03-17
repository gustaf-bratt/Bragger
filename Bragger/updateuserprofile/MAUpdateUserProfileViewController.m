//
//  MAUpdateUserProfileViewController.m
//  Bragger
//
//  Created by vino on 06/03/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import "MAUpdateUserProfileViewController.h"
#import "MASingleton.h"
#import "Constant.h"

@interface MAUpdateUserProfileViewController ()
{
		Reachability *reachability;
	UIAlertView *alert4Connectivity;
	BOOL isAlertShowing;

}
@end

@implementation MAUpdateUserProfileViewController
@synthesize emailIdTxt;
@synthesize nickNameTxt;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
	{
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
	
    // Do any additional setup after loading the view from its nib.
	emailIdTxt.text =  [[NSUserDefaults standardUserDefaults] objectForKey:@"email_id"];
	nickNameTxt.text =  [[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"];
	NSLog(@"%@,%@",[[NSUserDefaults standardUserDefaults] objectForKey:@"email_id"],[[NSUserDefaults standardUserDefaults] objectForKey:@"nickname"]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// hide keyboard
- (IBAction)act_HideKeyboard:(id)sender
{
	[nickNameTxt resignFirstResponder];
}

- (IBAction)act_Submit:(id)sender
{
	// check nickname is empty
	if (nickNameTxt.text.length == 0)
	{
		UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message:@"Please Enter NickName "
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		
		[alertsuccess show];
	}
	// check ninckname has less than 5 char
	else if (nickNameTxt.text.length < 6)
	{
		UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message:@" Nickname should have minimum 6 charcters "
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertsuccess show];
	}
	// check email is empty
/*	else	if (emailIdTxt.text.length == 0)
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message:@"Please Enter Email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertsuccess show];
    }
	// validate email
    else if(![[MASingleton sharedManager] validateEmail:emailIdTxt.text])
    {
		UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message:@"Please enter valid email id"
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		
		[alertsuccess show];
    } */
	// update user profile api call to change nickname and email
	else
	{
		NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
		NSString *sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_id"];
		NSString *fullname = [[NSUserDefaults standardUserDefaults] objectForKey:@"fullname"];
		NSString *urlAsString = GETAPILINK(@"memberwebs/edit/");
		urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];
		urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];
		urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&nickname=%@",nickNameTxt.text]];
		urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&email=%@",emailIdTxt.text]];
		urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&fullname=%@",fullname]];
		NSString *properlyEscapedURL = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSURL *url = [NSURL URLWithString:properlyEscapedURL];
		NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
		[urlRequest setTimeoutInterval:30.0f];
		[urlRequest setHTTPMethod:@"POST"];
		NSURLResponse *response = nil;
		NSError *error = nil;
		NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
		if ([data length] >0  && error == nil)
		{
			error = nil;
			id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
			if (jsonObject != nil && error == nil)
			{
				if ([jsonObject isKindOfClass:[NSDictionary class]])
				{
				    NSMutableDictionary *deserializedDictionary = jsonObject;
					NSString *msgFailStr = (NSString*)[deserializedDictionary objectForKey:@"message"];
					UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message:msgFailStr
																		  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
					[alertsuccess show];
				}
			}
		}
		else if ([data length] == 0 && error == nil)
		{
			NSLog(@"Nothing was downloaded.");
		}
		else if (error != nil)
		{
			NSLog(@"Error happened = %@", error);
		}
	}
}

- (IBAction)act_Back:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
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
