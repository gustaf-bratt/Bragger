//
//  MAAppDelegate.m
//  Bragger
//
//  Created by GaoShen on 2/2/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)


/*
 Chartboost IDs
 App ID: 53552b6dc26ee451e4bee05f
 App Signature: 26474746b2f0e9d264166bf0dcaf2446e481eb3b
 */

#define CHARTBOOST_APP_ID  @"53552b6dc26ee451e4bee05f";
#define CHARTBOOST_APP_SIGNATURE  @"26474746b2f0e9d264166bf0dcaf2446e481eb3b";

#import "MAAppDelegate.h"

#import "Chartboost.h"
#import "MABraggerLoginViewController.h"
#import "MASignUpEmailViewController.h"
#import "MABraggingStreamViewController.h"
#import "Reachability.h"

//#import "FP.h"

static NSString * const kClientID = @"28061136802-rc8khbjif7smpkfvkqm78fn35o5gu0cp.apps.googleusercontent.com";



@implementation MAAppDelegate
//@synthesize bool_InternetConnection;
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
 
  [GPPSignIn sharedInstance].clientID = kClientID;
 
	
    Reachability *reachability = [Reachability reachabilityWithHostName:@"www.apple.com"];
	
    // Start Monitori
    [reachability startNotifier];
	
 
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
	NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"UserDefaults" ofType:@"plist"]];
	[[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
    // Override point for customization after application launch.
   
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isLoggedIn"] == NO)
	{
		viewController = [[MABraggerLoginViewController alloc] initWithNibName:@"MABraggerLoginViewController_iPhone" bundle:nil];
		self.window.rootViewController = viewController;
	}
	else
	{
		viewController2 = [[MABraggingStreamViewController alloc] initWithNibName:@"MABraggingStreamViewController" bundle:nil];
		self.window.rootViewController = viewController2;
	}
		
 
 [self.window makeKeyAndVisible];
 

 // Whenever a person opens the app, check for a cached session
 if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded)
 {
  // If there's no cached session, we will show a login button
 }
 else
 {
  
  
//  UIButton *loginButton = [self.customLoginViewController loginButton];
//  [loginButton setTitle:@"Log in with Facebook" forState:UIControlStateNormal];
 }

 
    return YES;
}

// Chart Boost Integration
- (void)didFailToLoadMoreApps
{
    NSLog(@"failure to load more apps");
}
- (void)didDismissInterstitial:(NSString *)location
{
    NSLog(@"dismissed interstitial at location %@", location);
    
    [[Chartboost sharedChartboost] cacheInterstitial:location];
}
- (void)didDismissMoreApps
{
    NSLog(@"dismissed more apps page, re-caching now");
    
    [[Chartboost sharedChartboost] cacheMoreApps];
}
- (BOOL)shouldRequestInterstitialsInFirstSession
{
    return YES;
}
- (BOOL)shouldDisplayInterstitial:(NSString *)location {
    NSLog(@"about to display interstitial at location %@", location);
    
    // For example:
    // if the user has left the main menu and is currently playing your game, return NO;
    
    // Otherwise return YES to display the interstitial
    return YES;
}


////Update By Sabari 22/March
////Check Internet Connection
//- (BOOL) connectedToNetwork
//{
//    Reachability* reachability = [Reachability reachabilityWithHostName:www.apple.com];
//    NetworkStatus remoteHostStatus = [reachability currentReachabilityStatus];
//    
//    if(remoteHostStatus == NotReachable)
//    {
//        bool_InternetConnection =NO;
//        UIAlertView *alert_InternetConnection = [[UIAlertView alloc] initWithTitle:@"Bragger" message:@"The Internet connection appears to be offline." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        
//        [alert_InternetConnection show];
//
//    }
//    else
//    {
//        bool_InternetConnection = TRUE;
//    }
//    //    NSLog(bool_InternetConnection ? @"Yes" : @"No");
//    return bool_InternetConnection;
//}



- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    [self connectedToNetwork];
    
    // Initialize Chartboost
    Chartboost *cb = [Chartboost sharedChartboost];
    
    /*
     * Add your own app id & signature. These can be found on App Edit page for your app in the Chartboost dashboard
     *
     * Notes:
     * 1) BE SURE YOU USE YOUR OWN CORRECT APP ID & SIGNATURE!
     * 2) We cant help if it is missing or incorrect in a live app. You will have to resubmit.
     */
   // cb.delegate = self;
    /*
     CHARTBOOST_APP_ID;
     CHARTBOOST_APP_SIGNATURE;
     */
    // UnComment this two line and Add appID and appSignature
    cb.appId = CHARTBOOST_APP_ID;
    cb.appSignature = CHARTBOOST_APP_SIGNATURE;
    
    
    // Begin a user session. This should be done once per boot
    [cb startSession];
    
    // Cache an interstitial at the default location
 //   [cb cacheInterstitial];
    //
    //    // Cache an interstitial at some named locations -- (Pro Tip: do this!)
    //    [cb cacheInterstitial:@"After level 1"];
    //    [cb cacheInterstitial:@"Pause screen"];
    
    
    /*
     * Once cached, use showInterstitial to display the interstitial immediately like this:
     *
     * [cb showInterstitial:@"After level 1"];
     *
     * Notes:
     * 1) Each named location has it's own cache, only one interstitial is stored per named location
     * 2) Cached interstitials are deleted as soon as they're shown
     * 3) If no interstitial is cached for that location, showInterstitial will load one on the fly from Chartboost
     *
     * Pro Tip: Implement didDismissInterstitial to immediately re-cache interstitials by location (see below)
     *
     */
    
    // Cache the more apps page so it's loaded & ready
    ////[cb cacheMoreApps];
    [cb showMoreApps];
    
    
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.

    
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
 [FBAppEvents activateApp];
 [FBAppCall handleDidBecomeActive];
    
    
 //   [FP reportAppKey:@"534db3bf63d28" secretKey:@"NTM0ZGIzYmY2M2RkNQ=="];
 
}

- (void)applicationWillTerminate:(UIApplication *)application
{
 
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[FBSession activeSession] close];
}
- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController{
    //NSUInteger index=[[tabBarController viewControllers] indexOfObject:viewController];
    
   return YES;
}

#pragma mark - facebook
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
 // If the session was opened successfully
 if (!error && state == FBSessionStateOpen){
  NSLog(@"Session opened");
  // Show the user the logged-in UI
  [self userLoggedIn];
  return;
 }
 if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
  // If the session is closed
  NSLog(@"Session closed");
  // Show the user the logged-out UI
  [self userLoggedOut];
 }
 
 // Handle errors
 if (error){
  NSLog(@"Error");
  NSString *alertText;
  NSString *alertTitle;
  // If the error requires people using an app to make an action outside of the app in order to recover
  if ([FBErrorUtility shouldNotifyUserForError:error] == YES){
   alertTitle = @"Something went wrong";
   alertText = [FBErrorUtility userMessageForError:error];
   [self showMessage:alertText withTitle:alertTitle];
  } else {
   
   // If the user cancelled login, do nothing
   if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
    NSLog(@"User cancelled login");
    
    // Handle session closures that happen outside of the app
   } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession){
    alertTitle = @"Session Error";
    alertText = @"Your current session is no longer valid. Please log in again.";
    [self showMessage:alertText withTitle:alertTitle];
    
    // For simplicity, here we just show a generic message for all other errors
    // You can learn how to handle other errors using our guide: https://developers.facebook.com/docs/ios/errors
   } else {
    //Get more error information from the error
    NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
    
    // Show the user an error message
    alertTitle = @"Something went wrong";
    alertText = [NSString stringWithFormat:@"Please retry. \n\n If the problem persists contact us and mention this error code: %@", [errorInformation objectForKey:@"message"]];
    [self showMessage:alertText withTitle:alertTitle];
   }
  }
  // Clear this token
  [FBSession.activeSession closeAndClearTokenInformation];
  // Show the user the logged-out UI
  [self userLoggedOut];
 }
}

// Show the user the logged-out UI
- (void)userLoggedOut
{
 
}

// Show the user the logged-in UI
- (void)userLoggedIn
{
 
}

// Show an alert message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
 [[[UIAlertView alloc] initWithTitle:title
                             message:text
                            delegate:self
                   cancelButtonTitle:@"OK!"
                   otherButtonTitles:nil] show];
}

// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
// Override application:openURL:sourceApplication:annotation to call the FBsession object that handles the incoming URL
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
 
 return ([FBSession.activeSession handleOpenURL:url] || [GPPURLHandler handleURL:url sourceApplication:sourceApplication annotation:annotation]);

}





@end
