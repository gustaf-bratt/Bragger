//
//  MASettingsViewController.m
//  Bragger
//
//  Created by vino on 05/03/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import "MASettingsViewController.h"
#import "MABraggerLoginViewController.h"
#import "MAUpdateUserProfileViewController.h"
#include <FacebookSDK/FacebookSDK.h>
#include "FHSTwitterEngine.h"
#import "Reachability.h"
#import "Constant.h"

@interface MASettingsViewController ()
{
	Reachability *reachability;
	UIAlertView *alert4Connectivity;
	BOOL isAlertShowing;
	NSData *imageData;
	

}
@end

@implementation MASettingsViewController

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
	
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// log out btn action
- (IBAction)act_LogOut:(id)sender
{
	[self logOutServer];
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLoggedIn"];
	[[FBSession activeSession] closeAndClearTokenInformation];
	[FBSession setActiveSession:nil];
	[[GPPSignIn sharedInstance] signOut];
	[[FHSTwitterEngine sharedEngine] clearAccessToken];
	MABraggerLoginViewController *viewController = [[MABraggerLoginViewController alloc] initWithNibName:@"MABraggerLoginViewController_iPhone" bundle:nil];
	[self presentViewController:viewController animated:YES completion:nil];

}

// cahnge pwd btn action
- (IBAction)act_ChangePassword:(id)sender
{
	MAChangePwdViewController *viewController = [[MAChangePwdViewController alloc] initWithNibName:@"MAChangePwdViewController" bundle:nil];
	[self presentViewController:viewController animated:YES completion:nil];
}

// back btn action
- (IBAction)act_Back:(id)sender
{
	[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - profile photo

// change profile pic btn action
- (IBAction)act_ChangeProfilePic:(id)sender
{
	UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:Nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles: @"Choose From Library",@"Take Photo", nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleDefault;
	[popupQuery showInView:self.view];
}

// update yser profile btn action to update nickname and email id
- (IBAction)act_UpdateUserProfile:(id)sender
{
	MAUpdateUserProfileViewController *viewController = [[MAUpdateUserProfileViewController alloc] initWithNibName:@"MAUpdateUserProfileViewController" bundle:nil];
	[self presentViewController:viewController animated:YES completion:nil];
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
	
	imageData = UIImagePNGRepresentation([info objectForKey:UIImagePickerControllerOriginalImage]);
	
	HUD = [[MBProgressHUD alloc] initWithView:self.view];
	[self.view addSubview:HUD];
	[self.view bringSubviewToFront:HUD];
	
	HUD.dimBackground = YES;
	
	// Regiser for HUD callbacks so we can remove it from the window at the right time
	HUD.delegate = self;
	
	// Show the HUD while the provided method executes in a new thread
	[HUD showWhileExecuting:@selector(postPhotoTask) onTarget:self withObject:nil animated:YES];
	
	
	// change profile pic api to change user profile pic
	}


-(void)postPhotoTask
{
	NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    NSString *sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_id"];
	
	NSString *urlAsString = GETAPILINK(@"memberwebs/UserPhoto/");
	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];
	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];
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
//	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//	[NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse *response, NSData *data,NSError *error)
//	 {
//		 if ([data length] >0 && error == nil)
//		 {
//			 NSString *html = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//			 NSLog(@"HTML = %@", html);
//		 }
//		 else if ([data length] == 0 && error == nil)
//		 {
//			 NSLog(@"Nothing was downloaded.");
//		 }
//	 }];
	
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
	
	NSLog(@"Image Return String: %@", returnString);


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


-(void)logOutServer
{
	//http://ws.getbragger.com/memberwebs/savelogforlogout/?user_id=20&session_id=d5bf1bde4626221cd15823ddbb298cd8
    
	NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    NSString *sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_id"];

	NSString *urlAsString = GETAPILINK(@"memberwebs/savelogforlogout/");
	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];
	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];
	
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
				NSLog(@"Success:%@",jsonObject);

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


@end
