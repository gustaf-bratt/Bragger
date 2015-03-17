//
//  MAAppDelegate.h
//  Bragger
//
//  Created by GaoShen on 2/2/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MABraggerLoginViewController.h"
#import "MABraggingStreamViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <GooglePlus/GooglePlus.h>
#import "Chartboost.h"


@class MAViewController;
@interface MAAppDelegate : UIResponder <UIApplicationDelegate,ChartboostDelegate>

{
	MABraggerLoginViewController *viewController;
	MABraggingStreamViewController *viewController2;
	
}
@property (strong, nonatomic) UIWindow *window;
//Update by Sabari 22/March
//Check Internet Connection
//@property BOOL bool_InternetConnection;
//- (BOOL) connectedToNetwork;

- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error;
- (void)userLoggedIn;
- (void)userLoggedOut;
@end
