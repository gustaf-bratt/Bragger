 //
//  MASignUpEmailViewController.m
//  Bragger
//
//  Created by GaoShen on 2/2/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)

#import "MASignUpEmailViewController.h"
#import "MAAppDelegate.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLGeocoder.h>
#import "MASingleton.h"
#import "Reachability.h"
#import "Constant.h"

@interface MASignUpEmailViewController ()
{
    NSString *emailStr;
    NSString *realNameStr;
    NSString *nickNameStr;
    NSString *passwordStr;
    NSString *confirmPassowrd;
    BOOL myLocalProperty12;
    NSString *newloacalStr;
    CLLocationManager *locationManager;
	Reachability *reachability;
	UIAlertView *alert4Connectivity;
	BOOL isAlertShowing;

	
}
@end

@implementation MASignUpEmailViewController
@synthesize btn_ProfilePicture,emailTxt,nickNameTxt,realNameTxt,confirmPasswordTxt,tabBarController,passwordTxt,window,istickclicked,deserializedDictionary,realNameStr;
@synthesize emailStr;
@synthesize pictureStr;
@synthesize isFromFB;
@synthesize isFromTwitter;
@synthesize isFromGoogle;
@synthesize TermsAndConditionWebVw;
@synthesize closeWebVwBtn;

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
	// initialize location manager
	
	

    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    // text field delgate
	emailTxt.delegate = self;
    nickNameTxt.delegate = self;
    realNameTxt.delegate = self;
	passwordTxt.delegate = self;
	confirmPasswordTxt.delegate = self;
	
	if (isFromFB == YES)
	{
		realNameTxt.text = realNameStr;
		emailTxt.text = emailStr;
		emailTxt.userInteractionEnabled = NO;
		realNameTxt.userInteractionEnabled = NO;
		NSString *str = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?width=125&height=125",pictureStr];
		NSURL *url_Image = [NSURL URLWithString:str];
		NSData *data_Image = [NSData dataWithContentsOfURL:url_Image];
		UIImage *tempimg_UserImage = [[UIImage alloc] initWithData:data_Image];
		[[btn_ProfilePicture layer] setCornerRadius:120/2];
		[[btn_ProfilePicture layer] setMasksToBounds:YES];
		[btn_ProfilePicture setImage:tempimg_UserImage forState:UIControlStateNormal];
	}
	if (isFromTwitter == YES)
	{
		realNameTxt.text = realNameStr;
		realNameTxt.userInteractionEnabled = NO;
		NSURL *url_Image = [NSURL URLWithString:pictureStr];
		NSData *data_Image = [NSData dataWithContentsOfURL:url_Image];
		UIImage *tempimg_UserImage = [[UIImage alloc] initWithData:data_Image];
		[[btn_ProfilePicture layer] setCornerRadius:120/2];
		[[btn_ProfilePicture layer] setMasksToBounds:YES];
		[btn_ProfilePicture setImage:[self imageWithImage:tempimg_UserImage scaledToSize:CGSizeMake(130, 130)] forState:UIControlStateNormal];
	}
	if (isFromGoogle == YES)
	{
		realNameTxt.text = realNameStr;
		emailTxt.text = emailStr;
		emailTxt.userInteractionEnabled = NO;
		realNameTxt.userInteractionEnabled = NO;
		NSURL *url_Image = [NSURL URLWithString:pictureStr];
		NSData *data_Image = [NSData dataWithContentsOfURL:url_Image];
		UIImage *tempimg_UserImage = [[UIImage alloc] initWithData:data_Image];
		[[btn_ProfilePicture layer] setCornerRadius:120/2];
		[[btn_ProfilePicture layer] setMasksToBounds:YES];
		[btn_ProfilePicture setImage:tempimg_UserImage forState:UIControlStateNormal];
	}
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
	[emailTxt resignFirstResponder];
}

// agree btn action
- (IBAction)act_TickBtn:(id)sender
{
	UIImage *imageone=[[UIImage alloc]init];
	imageone = [UIImage imageNamed:@"mark_Image1.png"];
	UIImage *imageTwo=[[UIImage alloc]init];
	UIButton *theButton = (UIButton *)sender;
	if ([theButton currentImage] == imageone)
	{
		[theButton setImage:imageTwo forState:UIControlStateNormal];
		istickclicked=NO;
	}
	else
	{
		[theButton setImage:imageone forState:UIControlStateNormal];
		istickclicked=YES;
	}
}

// move view up when keyboard is present
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

// text field delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
	[self animateTextView : YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	if (textField==emailTxt)
	{
		emailStr = textField.text;
	}
	else if (textField == realNameTxt)
	{
		realNameStr = textField.text;
	}
	else if(textField == nickNameTxt)
	{
		nickNameStr =textField.text;
	}
	else if (textField == passwordTxt)
	{
		passwordStr = textField.text;
	}
	else if (textField == confirmPasswordTxt)
	{
		confirmPassowrd = textField.text;
	}
	[self  animateTextView :NO];
}

#pragma mark - pwd validation

// check password is greater than 6 charc and less than 32 char
-(BOOL) isPasswordValid:(NSString *)pwd
{
    pwd = passwordTxt.text;
    if ( [pwd length]< 6 || [pwd length]>32 )
    {
		return NO;
    }
    else
    {
		return YES;
    }
}

#pragma mark - sign up

// sign up btn action
- (IBAction)act_SignUpBtn:(id)sender
{
	// check email is empty
/*	if (emailStr.length == 0)
    {
        UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message:@"Please Enter Email" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertsuccess show];
 
    }
	// validate email
    else if(![[MASingleton sharedManager] validateEmail:emailStr])
    {
		UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message:@"Please enter valid email id"
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		
		[alertsuccess show];
    } */
	/*// check realname is empty
	else  if (realNameStr.length == 0)
	{
		UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message:@"Please Enter RealName"
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		
		[alertsuccess show];
	} */
	// check nickname is empty
    if (nickNameStr.length == 0)
	{
		UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message:@"Please Enter alias "
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		
		[alertsuccess show];
		
	}
	// check nickname str length is less than 6
	else if (nickNameStr.length < 6)
	{
		UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message:@" Alias should have minimum 6 charcters "
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertsuccess show];
	}
	// check paswword is empty
	else  if (passwordStr.length == 0)
	{
		UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message:@"Please Enter password"
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertsuccess show];
		
	}
	// check password length is less than 6
	else if(![self isPasswordValid:passwordStr])
	{
		UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message:@"Please Enter password minimum 6 char "
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		
		[alertsuccess show];
	}
	// check confirm pwd is empty
	else if (confirmPassowrd.length == 0)
	{
		UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message:@"Please Enter confirm password"
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		
		[alertsuccess show];
		
	}
	// check pwd and confirm pwd are equal
	else if (![passwordStr isEqualToString:confirmPassowrd])
	{
		UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message:@"Password Mismatch"
															  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		
		[alertsuccess show];
	}
	// check agree terms and conditoins are selected
	else if (istickclicked==NO)
	{
		UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message:@"Please agree Terms and conditions" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
		[alertsuccess show];
	}
	// calls create user api
	else
	{
        // check email is empty
        if (emailStr.length == 0)
        {
            emailStr = nickNameStr; // set email to nickname
            realNameStr = nickNameStr; // set real name to nickname
                    
            UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Bragger" message:@"Don't want to provide your email? Cool, now you are truly anonymous!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertsuccess show];
        }

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
                    deserializedDictionary = jsonObject;
                    if ([[deserializedDictionary objectForKey:@"jsonstatus" ] isEqualToString:@"ok"])
                    {
						[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLoggedIn"];
						NSString *sessionID = (NSString *)[deserializedDictionary objectForKey:@"session_id" ];
						NSString *userID = (NSString *)[deserializedDictionary objectForKey:@"user_id"];
						[self sendProfilePic2server:btn_ProfilePicture.imageView.image sessionID:sessionID userID:userID];
						MABraggingStreamViewController *obj_AboutVC;
						NSString *nickName = (NSString *)[deserializedDictionary objectForKey:@"nickname"];
						NSString *email = (NSString *)[deserializedDictionary objectForKey:@"email"];
						NSString *fullName = (NSString *)[deserializedDictionary objectForKey:@"fullname"];
                        
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
                        emailStr = @""; // clear it
                        nickNameStr = @""; // clear it
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
}


#pragma mark - profile photo

// uer profile pic btn action
- (IBAction)act_UserProfileImage:(id)sender
{
	
	UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:Nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Choose From Library",@"Take Photo", nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
	[popupQuery showInView:self.view];
	
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
	switch (buttonIndex)
	{
		case 0:
		{
			//Check PhotoLibrary available or not
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
			{
				picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
				[self presentViewController:picker animated:YES completion:nil];
			}
		}
			break;
		case 1:
		{
			//Check Camera available or not
			if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
			{
				picker.sourceType = UIImagePickerControllerSourceTypeCamera;
				[self presentViewController:picker animated:YES completion:NULL];
			}
			else
			{
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
																message:@"device does not support camera!!"
															   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
				[alert show];
			}
			
		}
			break;
			
		default:
			break;
	}
}
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
	[self dismissViewControllerAnimated:YES completion:^{}];
	[[btn_ProfilePicture layer] setCornerRadius:120/2];
	[[btn_ProfilePicture layer] setMasksToBounds:YES];
	[btn_ProfilePicture setImage:[info objectForKey:UIImagePickerControllerOriginalImage] forState:UIControlStateNormal];
}

// send user profile picture to server
-(void)sendProfilePic2server:(UIImage *)img  sessionID:(NSString *)sessionID  userID:(NSString *) userID
{
	NSData *imageData = UIImagePNGRepresentation(img);
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

// get latitude and longitude of the location
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    [manager stopUpdatingLocation];
//    CLLocation *location1 = [[CLLocation alloc] initWithLatitude:13.0849823 longitude:80.2746612];
	CLGeocoder *geocoder = [[CLGeocoder alloc] init];
	[geocoder reverseGeocodeLocation: newLocation completionHandler: ^(NSArray *placemarks, NSError *error)
	 {
		 //Get nearby address

 		 NSString *latitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.latitude];
		 NSString *longtitude = [NSString stringWithFormat:@"%f",newLocation.coordinate.longitude];
		

		 [[NSUserDefaults standardUserDefaults] setObject:latitude forKey:@"latitude"];
		 [[NSUserDefaults standardUserDefaults] setObject:longtitude forKey:@"longtitude"];
		 [[NSUserDefaults standardUserDefaults] synchronize];
	 }];
}


// scale uiimage
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize
{
	UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
	[image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
	UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return newImage;
}

// back btn action
- (IBAction)act_BackButton:(id)sender
{
	if (isFromFB == YES)
	{
		[[FBSession activeSession] closeAndClearTokenInformation];
		[FBSession setActiveSession:nil];
	}
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - terms and conditions

// close terms and conditions btn action
- (IBAction)act_CloseTermsAndConditions:(id)sender
{
	TermsAndConditionWebVw.hidden = YES;
	closeWebVwBtn.hidden = YES;
}

// open terms and contions btn action
- (IBAction)act_OpenTermsAndConditions:(id)sender
{
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"settings" ofType:@"plist"];
	NSDictionary *settings = [[NSDictionary alloc] initWithContentsOfFile:path];
	TermsAndConditionWebVw.hidden = NO;
	closeWebVwBtn.hidden = NO;
	NSString *fullURL = (NSString *)[settings valueForKey:@"term&conditions"];
	NSURL *url = [NSURL URLWithString:fullURL];
	NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
	[TermsAndConditionWebVw loadRequest:requestObj];
}

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
