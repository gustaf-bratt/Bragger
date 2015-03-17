//
//  MAExuserLoginViewController.m
//  Bragger
//
//  Created by GaoShen on 2/7/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)

#import "MAUserLoginViewController.h"
#import "MABraggingStreamViewController.h"
#import "Reachability.h"
#import "Constant.h"

@interface MAUserLoginViewController ()
{
	Reachability *reachability;
	UIAlertView *alert4Connectivity;
	BOOL isAlertShowing;

}
@end

@implementation MAUserLoginViewController
@synthesize txt_EmailTxtExUser,txt_PasswordExUser;

#pragma mark - init
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - text field and delegates

// hide keyboard
- (IBAction)act_HideKeyboard:(id)sender
{
	[txt_EmailTxtExUser resignFirstResponder];
	
}

// forget password button action
- (IBAction)act_Forget:(id)sender
{
	txt_PasswordExUser.text = nil;
	if ([txt_EmailTxtExUser.text isEqualToString:@""])
	{
		
		UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message:@"Please enter email address"
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		
		[alertsuccess show];
		
	}
	else
	{
		[self forgetPwd];
	}
}

// back btn action
- (IBAction)act_Back:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -  login

// login button action
- (IBAction)act_Login:(id)sender
{
	
	if ([txt_EmailTxtExUser.text isEqualToString:@""])
	{
		UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message:@"Please enter alias or email address"
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		
		[alertsuccess show];
	}
	else
	{
		if ([txt_PasswordExUser.text isEqualToString:@""])
		{
			UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message:@"Please enter password "
																  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
			
			[alertsuccess show];
		}
		else
		{
            //[self performSelector:@selector(IndicatorShow) withObject:nil afterDelay:0.01f];
            
			NSString *urlAsString = GETAPILINK(@"memberwebs/ValidateLogin/");
			urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?email=%@",txt_EmailTxtExUser.text]];
			urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&password=%@",txt_PasswordExUser.text]];
			NSURL *url = [NSURL URLWithString:urlAsString];
			NSMutableURLRequest *urlRequest =
			[NSMutableURLRequest requestWithURL:url];
		    [urlRequest setTimeoutInterval:30.0f];
			[urlRequest setHTTPMethod:@"POST"];
			NSURLResponse *response = nil;
			NSError *error = nil;
			NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest
												 returningResponse:&response
															 error:&error];
			if ([data length] >0  && error == nil)
			{
				NSString *html =
				[[NSString alloc] initWithData:data
									  encoding:NSUTF8StringEncoding];
				NSLog(@"HTML = %@", html);
				error = nil;
				id jsonObject = [NSJSONSerialization
								 JSONObjectWithData:data
								 options:NSJSONReadingAllowFragments
								 error:&error];
				if (jsonObject != nil && error == nil)
				{
					NSDictionary *deserializedDictionary = jsonObject;
					MABraggingStreamViewController *obj_AboutVC;
					if ([[jsonObject objectForKey:@"status"] isEqualToString:@"ok"])
					{
						[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoggedIn"];
						NSString *sessionID = (NSString *)[deserializedDictionary objectForKey:@"session_id" ];
						NSString *userID = (NSString *)[deserializedDictionary objectForKey:@"id"];
						NSString *nickName = (NSString *)[deserializedDictionary objectForKey:@"nickname"];
						NSString *email = (NSString *)[deserializedDictionary objectForKey:@"email"];
						NSString *fullName = (NSString *)[deserializedDictionary objectForKey:@"fullname"];
						[[NSUserDefaults standardUserDefaults] setObject:sessionID forKey:@"session_id"];
						[[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"user_id"];
						[[NSUserDefaults standardUserDefaults] setObject:nickName forKey:@"nickname"];
						[[NSUserDefaults standardUserDefaults] setObject:email forKey:@"email_id"];
						[[NSUserDefaults standardUserDefaults] setObject:fullName forKey:@"fullname"];
						[[NSUserDefaults standardUserDefaults] synchronize];
						obj_AboutVC = [[MABraggingStreamViewController alloc] initWithNibName:@"MABraggingStreamViewController" bundle:nil];
						[self presentViewController:obj_AboutVC animated:YES completion:nil];
					}
					else
					{
						NSString *msg = [NSString stringWithFormat:@"%@",[jsonObject objectForKey:@"message"]];
						UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message:msg
																			  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
						[alertsuccess show];
					}
				}
				else if (error != nil)
				{
					NSLog(@"An error happened while deserializing the JSON data.");
				}
				else if ([data length] == 0 && error == nil)
				{
					NSLog(@"Nothing was downloaded.");
				}
				else if (error != nil){
					NSLog(@"Error happened = %@", error);
				}
				//[self performSelector:@selector(IndicatorHide) withObject:nil afterDelay:0.01f];
			}
		}
	}
	 
}


#pragma mark -  forget password

// forget password api call
- (void)forgetPwd
{
	NSString *urlAsString = GETAPILINK(@"forgotpassword/?user_id=&session_id=");
	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&nickname=%@",txt_EmailTxtExUser.text]];
	NSURL *url = [NSURL URLWithString:urlAsString];
	NSMutableURLRequest *urlRequest =
	[NSMutableURLRequest requestWithURL:url];
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
				NSDictionary *deserializedDictionary = jsonObject;
				UIAlertView *alert_Follower = [[UIAlertView alloc] initWithTitle:@"Bragger" message:[deserializedDictionary valueForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
				[alert_Follower show];
			}
		}
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
