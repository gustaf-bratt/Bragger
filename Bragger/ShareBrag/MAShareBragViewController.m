//
//  MAShareBragViewController.m
//  Bragger
//
//  Created by GaoShen on 2/5/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)
#import "UIViewController+MJPopupViewController.h"
#import "MAShareBragViewController.h"
#import "MABragPhotoViewController.h"
#import "MABragVideoViewController.h"
#import "MABragWriteViewController.h"
#import "MABragAudioViewController.h"
#import "MABraggingStreamViewController.h"
#import "MABraggerProfileViewController.h"
#import "MADiscoverBraggerViewController.h"
#import "Reachability.h"

@interface MAShareBragViewController ()
{
	BOOL myLocalProperty;
	Reachability *reachability;
	UIAlertView *alert4Connectivity;
	BOOL isAlertShowing;

}
@end

@implementation MAShareBragViewController
@synthesize view1;
@synthesize myProperty1,BragUserDetails2;

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

#pragma mark - load view
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

#pragma mark - brag audio
// brag audio btn action
- (IBAction)act_BragAudio:(id)sender
{
    MABragAudioViewController *obj_AboutVC;
    obj_AboutVC = [[MABragAudioViewController alloc] initWithNibName:@"MABragAudioViewController" bundle:nil];
    if (view1==0)
        obj_AboutVC.view2=0;
    else if (view1==1)
         obj_AboutVC.view2=1;
    else
        obj_AboutVC.view2=2;
    [self presentViewController:obj_AboutVC animated:YES completion:nil];
}

#pragma mark - brag photo
// brag photo btn action
- (IBAction)act_BragPhoto:(id)sender
{
    MABragPhotoViewController *obj_AboutVC;
    obj_AboutVC = [[MABragPhotoViewController alloc] initWithNibName:@"MABragPhotoViewController" bundle:nil];
    if (view1==0)
	{
        obj_AboutVC.view2=0;
    }
    else if (view1==1)
    {
        obj_AboutVC.view2=1;
	}
    else
    {
        obj_AboutVC.view2=2;
    }
    [self presentViewController:obj_AboutVC animated:YES completion:nil];
}

#pragma mark - brag video
// brag video btn action
- (IBAction)act_BragVideo:(id)sender
{
    MABragVideoViewController *obj_AboutVC;
	obj_AboutVC = [[MABragVideoViewController alloc] initWithNibName:@"MABragVideoViewController" bundle:nil];
    if (view1==0)
	{
        obj_AboutVC.view2=0;
    }
    else if (view1==1)
    {
        obj_AboutVC.view2=1;
    }
    else
    {
        obj_AboutVC.view2=2;
    }
    [self presentViewController:obj_AboutVC animated:YES completion:nil];
}

#pragma mark - brag write
// brag write btn action
- (IBAction)act_BragWrite:(id)sender
{
    MABragWriteViewController *obj_AboutVC;
    obj_AboutVC = [[MABragWriteViewController alloc] initWithNibName:@"MABragWriteViewController" bundle:nil];
    if (view1==0)
	{
        obj_AboutVC.view2=0;
    }
    else if (view1==1)
    {
        obj_AboutVC.view2=1;
	}
    else
    {
        obj_AboutVC.view2=2;
    }
    [self presentViewController:obj_AboutVC animated:YES completion:nil];
}

#pragma mark - close
// close btn action
- (IBAction)act_close:(id)sender
{
    if (view1==0)
    {
		MABraggingStreamViewController *obj_AboutVC;
		obj_AboutVC = [[MABraggingStreamViewController alloc] initWithNibName:@"MABraggingStreamViewController" bundle:nil];
		[self presentViewController:obj_AboutVC animated:NO completion:nil];
    }
	else if(view1==1)
    {
        MADiscoverBraggerViewController *obj_AboutVC;
        obj_AboutVC = [[MADiscoverBraggerViewController alloc] initWithNibName:@"MADiscoverBraggerViewController" bundle:nil];
        [self presentViewController:obj_AboutVC animated:NO completion:nil];
    }
    else
    {
        MABraggerProfileViewController *obj_AboutVC;
        obj_AboutVC = [[MABraggerProfileViewController alloc] initWithNibName:@"MABraggerProfileViewController" bundle:nil];
		[self presentViewController:obj_AboutVC animated:NO completion:nil];
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
