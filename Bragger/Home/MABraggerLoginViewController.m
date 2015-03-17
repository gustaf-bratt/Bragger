//
//  MABraggerLoginViewController.m
//  Bragger
//
//  Created by GaoShen on 2/2/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)
#import "MAUserLoginViewController.h"
#import "MABraggerLoginViewController.h"
#import "MABragVideoViewController.h"
#import "MABragPhotoViewController.h"
#import "MASignUpEmailViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import "MAAppDelegate.h"
#import "FHSTwitterEngine.h"
#import <Social/Social.h>
#import <GoogleOpenSource/GoogleOpenSource.h>
#import <GooglePlus/GooglePlus.h>
#import "MASingleton.h"
#import "Constant.h"

// twitter consumer and secret key
#define CONSUMER_KEY @"I8tqos8z2cuaNs7WoPW8AQ"
#define SECRECT_KEY @"Uxuzqg1zwK7VvgmWF6X1LjPnaKeY99R0VgyjI9O7om0"

// google plus client id
static NSString * const kClientID = @"28061136802-rc8khbjif7smpkfvkqm78fn35o5gu0cp.apps.googleusercontent.com";

static BOOL isBragAnn;

@interface MABraggerLoginViewController ()<FHSTwitterEngineAccessTokenDelegate>
{
	GPPSignIn *signIn;
	BOOL isTwitter;
	BOOL isFacebook;
	BOOL isGooglePlus;
    Reachability *reachability;
	UIAlertView *alert4Connectivity;
	BOOL isAlertShowing;

}
@end

@implementation MABraggerLoginViewController
@synthesize img_BraggerHomePage;


#pragma mark -  init
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
	
	// set twitter keys and delegates
	[[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:CONSUMER_KEY andSecret:SECRECT_KEY];
	[[FHSTwitterEngine sharedEngine]setDelegate:self];
	[[FHSTwitterEngine sharedEngine]loadAccessToken];

	// set brag annonumous to No
	isBragAnn = NO;

	// set google plus id
	[GPPSignInButton class];
	signIn = [GPPSignIn sharedInstance];
	signIn.shouldFetchGooglePlusUser = YES;
	signIn.shouldFetchGoogleUserEmail = YES;
	signIn.shouldFetchGoogleUserID = YES;
	signIn.clientID = kClientID;
	signIn.scopes = @[ @"profile" ];
	signIn.delegate = self;
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -  facebook
- (IBAction)act_Facebook:(id)sender
{
	NSArray *permissions = [[NSArray alloc] initWithObjects:@"email",nil];
	// Attempt to open the session. If the session is not open, show the user the Facebook login UX
	[FBSession openActiveSessionWithReadPermissions:permissions allowLoginUI:true completionHandler:^(FBSession *session,
																									  FBSessionState status,
																									  NSError *error)
	 {
		 // Did something go wrong during login? I.e. did the user cancel?
		 if (status == FBSessionStateClosedLoginFailed || status == FBSessionStateCreatedOpening)
		 {
			 // If so, just send them round the loop again
			 [[FBSession activeSession] closeAndClearTokenInformation];
			 [FBSession setActiveSession:nil];
			 FBSession* session = [[FBSession alloc] init];
			 [FBSession setActiveSession: session];
		 }
		 else
		 {
			 // Updates our game now we've logged in
			 // Save the session locally
			 // Query the username,first name,uid,and email id of the facebook user
			 NSString *query2 = [NSString stringWithFormat:@"SELECT name,email,uid FROM user WHERE  uid = me()"];
			 // Set up the query parameter
			 NSDictionary *queryParam2 = @{ @"q": query2 };
			 // Make the API request that uses FQL
			 [FBRequestConnection startWithGraphPath:@"/fql" parameters:queryParam2  HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection,
																														   id result,
																														   NSError *error)
			  {
				  if (error)
				  {
					  NSLog(@"ERror");
				  }
				  else
				  {
					  if (session.isOpen)
					  {
						  isFacebook = YES;
						  isTwitter = NO;
						  isGooglePlus = NO;
						  NSArray *arr = result[@"data"];
						  NSString *nickName = arr[0][@"name"];
						  NSString *realName = arr[0][@"name"];
						  NSString *email = arr[0][@"email"];
						  NSString *password = arr[0][@"uid"];
						  
						  NSLog(@"Facebook Email : %@",email);
						  
						   NSArray *emailSplitArr = [email componentsSeparatedByString:@"@"];
						   NSString *addemailstr = [NSString stringWithFormat:@"fb%@",[emailSplitArr objectAtIndex:1]];
						   NSString *finalemail = [NSString stringWithFormat:@"%@@%@",[emailSplitArr objectAtIndex:0],addemailstr];
						NSLog(@"Facebook Email : %@",finalemail);
						  [self signUp:nickName password:password email:finalemail realName:realName picture:password];
			              
//						  MASignUpEmailViewController *obj_AboutVC;
//						  obj_AboutVC = [[MASignUpEmailViewController alloc] initWithNibName:@"MASignUpEmailViewController_iPhone" bundle:nil];
//						  obj_AboutVC.realNameStr = arr[0][@"name"];
//						  obj_AboutVC.pictureStr = arr[0][@"uid"];
//						  obj_AboutVC.emailStr = arr[0][@"email"];
//						  obj_AboutVC.isFromFB = YES;
//						  [self presentViewController:obj_AboutVC animated:YES completion:nil];
					  }
				  }
			  }];
		 }
		 
	 }];
}

#pragma mark -  g+
- (IBAction)act_GooglePlus:(id)sender
{
 [signIn authenticate];
}

-(void)refreshInterfaceBasedOnSignIn
{
	 if ([[GPPSignIn sharedInstance] authentication])
	 {
		  // get name,picture and email id fron google + account
		  GTLPlusPerson *person = [GPPSignIn sharedInstance].googlePlusUser;
		  if (person == nil)
			  return;
		  NSString *truncatedString = [person.image.url substringToIndex:[person.image.url length]-2];
		  NSString *imageUrl = [NSString stringWithFormat:@"%@125",truncatedString];
		  NSString *name = person.displayName;
		  NSString *uid = person.identifier;
		 NSString *email = (NSString*)[GPPSignIn sharedInstance].userEmail;
		 NSArray *emailSplitArr = [email componentsSeparatedByString:@"@"];
		 NSString *addemailstr = [NSString stringWithFormat:@"g%@",[emailSplitArr objectAtIndex:1]];
		 NSString *finalemail = [NSString stringWithFormat:@"%@@%@",[emailSplitArr objectAtIndex:0],addemailstr];
//		 NSLog(@"Google + Email : %@",emailSplitArr);
//		  NSLog(@"Google + Email : %@",finalemail);
	[self signUp:name password:uid email:finalemail realName:name picture:imageUrl];
//		  MASignUpEmailViewController *obj_AboutVC;
//		  obj_AboutVC = [[MASignUpEmailViewController alloc] initWithNibName:@"MASignUpEmailViewController_iPhone" bundle:nil];
//		  obj_AboutVC.realNameStr = person.displayName;
//		  obj_AboutVC.pictureStr  = imageUrl;
//		  obj_AboutVC.emailStr = (NSString*)[GPPSignIn sharedInstance].userEmail;
//		  obj_AboutVC.isFromGoogle = YES;
//		  [[[[UIApplication sharedApplication] delegate] window] setRootViewController:obj_AboutVC];
	 }
}


- (void)finishedWithAuth: (GTMOAuth2Authentication *)auth
                   error: (NSError *) error
{
	if (error)
	{
		// Do some error handling here.
	}
	else
	{
		[self refreshInterfaceBasedOnSignIn];
	}
}

#pragma mark -  signup,login,brag annon

// sign up button action
- (IBAction)act_SignUpEmail:(id)sender
{
	MASignUpEmailViewController *obj_AboutVC;
	obj_AboutVC = [[MASignUpEmailViewController alloc] initWithNibName:@"MASignUpEmailViewController_iPhone" bundle:nil];
	[self presentViewController:obj_AboutVC animated:YES completion:nil];
}

// brag anonymous button action
- (IBAction)act_BragAnonymously:(id)sender
{
	isBragAnn = YES;
	MABraggingStreamViewController *obj_AboutVC;
	obj_AboutVC = [[MABraggingStreamViewController alloc] initWithNibName:@"MABraggingStreamViewController" bundle:nil];
	[self presentViewController:obj_AboutVC animated:YES completion:nil];
}

// login button action
- (IBAction)act_Login:(id)sender
{
	MAUserLoginViewController *obj_AboutVC;
	obj_AboutVC = [[MAUserLoginViewController alloc] initWithNibName:@"MAUserLoginViewController" bundle:nil];
	[self presentViewController:obj_AboutVC animated:YES completion:nil];
}

// check whether the brag anonymous is selected or not
+(BOOL) isBragAnnIsSelected
{
 return isBragAnn;
}

#pragma mark -  twitter

// twitter button action
- (IBAction)act_twitter:(id)sender
{
//	UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success)
//	{
//		if(success)
//		{
			// get user name and picture from twitter
			isFacebook = NO;
			isGooglePlus = NO;
			isTwitter = YES;
			NSString *name = FHSTwitterEngine.sharedEngine.authenticatedUsername;
			NSString *uid = FHSTwitterEngine.sharedEngine.authenticatedID;
			NSString *picStr = [[FHSTwitterEngine sharedEngine] getProfileImageForUsername:FHSTwitterEngine.sharedEngine.authenticatedUsername andSize:2];
			[self signUp:name password:uid email:[NSString stringWithFormat:@"%@@twgmail.com",name] realName:name picture:picStr];
//			MASignUpEmailViewController *obj_AboutVC;
//			obj_AboutVC = [[MASignUpEmailViewController alloc] initWithNibName:@"MASignUpEmailViewController_iPhone" bundle:nil];
//			obj_AboutVC.realNameStr = name;
//			obj_AboutVC.pictureStr = [[FHSTwitterEngine sharedEngine] getProfileImageForUsername:FHSTwitterEngine.sharedEngine.authenticatedUsername andSize:2];
//			obj_AboutVC.isFromTwitter = YES;
//			[[[[UIApplication sharedApplication] delegate] window] setRootViewController:obj_AboutVC];
           
			
//		}
//	}];
//	[self presentViewController:loginController animated:YES completion:nil];
}

// twitter store access token
- (void)storeAccessToken:(NSString *)accessToken
{
	[[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
}

// load twitter access token
- (NSString *)loadAccessToken
{
	return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}


-(void)signUp:(NSString *)nickNameStr password:(NSString *)passwordStr email:(NSString *)emailStr realName:(NSString *)realNameStr picture:(NSString*)pictureStr
{
	NSString *urlAsString = GETAPILINK(@"memberwebs/CreateUser/");
	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?nickname=%@",nickNameStr]];
	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&password=%@",passwordStr]];
	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&email=%@",emailStr]];
	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&fullname=%@",realNameStr]];
	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&user_location=%@",[[MASingleton sharedManager] getLocation]]];
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
		id jsonObject = [NSJSONSerialization  JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		if (jsonObject != nil && error == nil)
		{
			if ([jsonObject isKindOfClass:[NSDictionary class]])
			{
				NSMutableDictionary  *deserializedDictionary = jsonObject;
				NSLog(@"json:%@",deserializedDictionary);
				
				//message = "Member already exist.";
				if ([[deserializedDictionary objectForKey:@"message"] isEqualToString:@"Member already exist."])
				{
					[self Login:emailStr password:passwordStr];
				}
				else
				{
					if ([[deserializedDictionary objectForKey:@"jsonstatus" ] isEqualToString:@"ok"])
					{
						[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoggedIn"];
						NSString *sessionID = (NSString *)[deserializedDictionary objectForKey:@"session_id" ];
						NSString *userID = (NSString *)[deserializedDictionary objectForKey:@"user_id"];
						[self sendProfilePic2server:sessionID userID:userID picStr:pictureStr];
						MABraggingStreamViewController *obj_AboutVC;
						NSString *nickName = (NSString *)[deserializedDictionary objectForKey:@"nickname"];
						NSString *email = (NSString *)[deserializedDictionary objectForKey:@"email"];
						//NSString *fullName = (NSString *)[deserializedDictionary objectForKey:@"fullname"];
                        NSString *fullName = nickName;
                        
						[[NSUserDefaults standardUserDefaults] setObject:nickName forKey:@"nickname"];
						[[NSUserDefaults standardUserDefaults] setObject:email forKey:@"email_id"];
						[[NSUserDefaults standardUserDefaults] setObject:sessionID forKey:@"session_id"];
						[[NSUserDefaults standardUserDefaults] setObject:userID forKey:@"user_id"];
						[[NSUserDefaults standardUserDefaults] setObject:fullName forKey:@"fullname"];
						[[NSUserDefaults standardUserDefaults] synchronize];
						obj_AboutVC = [[MABraggingStreamViewController alloc] initWithNibName:@"MABraggingStreamViewController" bundle:nil];
						obj_AboutVC.REGUSER=1;
						[self presentViewController:obj_AboutVC animated:YES completion:nil];
					}
					else
					{
						NSString *msgFailStr = (NSString*)[deserializedDictionary objectForKey:@"message"];
						UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message:msgFailStr
																			  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
						[alertsuccess show];
					}
				}
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



// send user profile picture to server
-(void)sendProfilePic2server:(NSString *)sessionID  userID:(NSString *) userID picStr:(NSString *)picStr
{
	UIImage *tempimg_UserImage;
	if (isFacebook == YES)
	{
		NSString *str = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=125&height=125",picStr];
		NSURL *url_Image = [NSURL URLWithString:str];
		NSData *data_Image = [NSData dataWithContentsOfURL:url_Image];
		tempimg_UserImage= [[UIImage alloc] initWithData:data_Image];
	}
	else if (isTwitter == YES)
	{
		NSURL *url_Image = [NSURL URLWithString:picStr];
		NSData *data_Image = [NSData dataWithContentsOfURL:url_Image];
		tempimg_UserImage = [[UIImage alloc] initWithData:data_Image];
	}
	else if(isGooglePlus == YES)
	{
		NSURL *url_Image = [NSURL URLWithString:picStr];
		NSData *data_Image = [NSData dataWithContentsOfURL:url_Image];
		tempimg_UserImage = [[UIImage alloc] initWithData:data_Image];
	}
	NSData *imageData = UIImagePNGRepresentation(tempimg_UserImage);
	NSLog(@"imag:%@",imageData);
	NSString *urlAsString = GETAPILINK(@"memberwebs/UserPhoto/");
	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userID]];
	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionID]];
	NSURL *url = [NSURL URLWithString:urlAsString];
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:url];
	[request setHTTPMethod:@"POST"];
	NSString *boundary = @"---------------------------14737809831466499882746641449";
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"user_profile_image\"; filename=\"qwerty.png\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:imageData]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[request setHTTPBody:body];
	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data,NSError *error)
	 {
		 if ([data length] >0 && error == nil){ NSString *html =
			 [[NSString alloc] initWithData:data
								   encoding:NSUTF8StringEncoding];
			 NSLog(@"HTML = %@", html);
		 }
		 else if ([data length] == 0 && error == nil)
		 {
			 NSLog(@"Nothing was downloaded.");
		 }
	 }];
	
}


-(void)Login:(NSString *)email password:(NSString *)password
{
NSString *urlAsString = GETAPILINK(@"memberwebs/ValidateLogin/");
urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?email=%@",email]];
urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&password=%@",password]];
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
			[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLoggedIn"];
			[[FBSession activeSession] closeAndClearTokenInformation];
			[FBSession setActiveSession:nil];
			[[GPPSignIn sharedInstance] signOut];
			[[FHSTwitterEngine sharedEngine] clearAccessToken];
			
			
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
