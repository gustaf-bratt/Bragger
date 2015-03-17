//
//  MADiscoverBraggerViewController.m
//  Bragger
//
//  Created by GaoShen on 2/2/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)

#import "UIViewController+MJPopupViewController.h"
#import "MADiscoverBraggerViewController.h"
#import "MABraggingStreamViewController.h"
#import "MAShareBragViewController.h"
#import "MABraggerProfileViewController.h"
#import "MASingleton.h"
#import "MASettingsViewController.h"
#import "Reachability.h"
#import "Constant.h"

BOOL isbtn_PostLikeSelected[0];
BOOL isbtn_ShowOffSelected[0];
BOOL isbtn_CommentSelected[0];

@interface MADiscoverBraggerViewController ()
{
    NSString *userId;
    NSString *sessionId;
    NSString *str_latitude;
    NSString *str_longitude;
    NSMutableArray *fullNameArr;
    NSMutableArray *userImageArr;
    NSMutableArray *locationArr;
    NSMutableArray *memberUserIdArr;
    NSMutableArray *totalDisLike4Post;
    NSMutableArray *postIdArr;
    NSMutableArray *postMediaFileArr;
    NSMutableArray *postMediaTypeArr;
    NSMutableArray *hashTagArr;
    NSMutableArray *totalLike4Post;
    NSMutableArray *isFollowingFlagArr;
    NSMutableArray *postTitleArr;
    NSMutableArray *postTimeArr;
    NSMutableArray *totalCommentArr;
    NSString *countLike4Post;
	Reachability *reachability;
	UIAlertView *alert4Connectivity;
	BOOL isAlertShowing;
	NSMutableArray *thumbnailVideoArr;

    
}
@end

@implementation MADiscoverBraggerViewController

@synthesize seeg_DiscoverSegmentation,coll_DiscoverBragger,filteredBragger,mainSearchBar,isFiltered,filteredBraggerIndex;

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
    /*
	switch (seeg_DiscoverSegmentation.selectedSegmentIndex)
    {
        case 0:
            [self DiscoverPostToserver:@"top"];
            [coll_DiscoverBragger reloadData];
            break;
        case 1:
            [self DiscoverPostToserver:@"discoverfollowing"];
            [coll_DiscoverBragger reloadData];
            break;
        case 2:
            [self DiscoverPostToserver:@"nearby"];
            [coll_DiscoverBragger reloadData];
            break;
        default:
            break;
    }
    */

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
    
    userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_id"];
    str_latitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
    str_longitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"longtitude"];
    
    
    UIFont *font = [UIFont systemFontOfSize:11.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    [seeg_DiscoverSegmentation setTitleTextAttributes:attributes
                                             forState:UIControlStateNormal];
    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [UIColor colorWithRed:63.0/255.0 green:170.0/255.0 blue:237.0/255.0 alpha:1],UITextAttributeTextColor, nil]
                                                   forState:UIControlStateSelected];
    
    
    [coll_DiscoverBragger registerNib:[UINib nibWithNibName:@"MADiscoverBraggerCustomCell" bundle:nil] forCellWithReuseIdentifier:@"CELL"];
    
    [self DiscoverPostToserver:@"top"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidAppear:(BOOL)animated
{
}

#pragma mark - Segmented Control (Top Braggers, NearBy Braggers)

- (void) onSwitchFilters
{
    switch (seeg_DiscoverSegmentation.selectedSegmentIndex)
    {
        case 0:
            [self DiscoverPostToserver:@"top"];
            [coll_DiscoverBragger reloadData];
            break;
        case 1:
            [self DiscoverPostToserver:@"discoverfollowing"];
            [coll_DiscoverBragger reloadData];
            break;
        case 2:
            [self DiscoverPostToserver:@"nearby"];
            [coll_DiscoverBragger reloadData];
            break;
        default:
            break;
    }
}

// Select SegmentControl To See Top, DiscoverFollowing, nearBy Braggers
- (IBAction)act_ChangeSeg:(id)sender
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [self.view bringSubviewToFront:HUD];
    HUD.dimBackground = YES;
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    // Show the HUD while the provided method executes in a new thread
    [HUD showWhileExecuting:@selector(onSwitchFilters) onTarget:self withObject:nil animated:YES];
}

// For Setting Purpose
- (IBAction)act_Settings:(id)sender
{
	MASettingsViewController *settingVC = [[MASettingsViewController alloc] initWithNibName:@"MASettingsViewController" bundle:nil];
	[self presentViewController:settingVC animated:YES completion:nil];
    
}

#pragma mark - Tab Bar & Navigation Bar


- (IBAction)act_Braggers:(id)sender
{
    
}

// Go to SharBrag Screen
- (IBAction)act_ShareBrag:(id)sender
{
    MAShareBragViewController *obj_ShareBragVC;
    obj_ShareBragVC = [[MAShareBragViewController alloc] initWithNibName:@"MAShareBragViewController" bundle:nil];
	obj_ShareBragVC.view1=1;
    [self presentPopupViewController:obj_ShareBragVC animationType:MJPopupViewAnimationFade];
}

// Go To BraggingStream Screen
- (IBAction)act_Bragging:(id)sender
{
    MABraggingStreamViewController *obj_BraggingStreamVC;
    obj_BraggingStreamVC = [[MABraggingStreamViewController alloc] initWithNibName:@"MABraggingStreamViewController" bundle:nil];
    [self presentViewController:obj_BraggingStreamVC animated:YES completion:nil];
}

// Back Button
- (IBAction)act_BackDiscover:(id)sender
{
    MABraggingStreamViewController *obj_BraggingStreamVC;
    obj_BraggingStreamVC = [[MABraggingStreamViewController alloc] initWithNibName:@"MABraggingStreamViewController" bundle:nil];
    [self presentPopupViewController:obj_BraggingStreamVC animationType:MJPopupViewAnimationSlideLeftRight];
    
}

#pragma mark - Get Discover Post
// Get All Braggers Data from the Server
-(void)DiscoverPostToserver:(NSString *)postFilterType
{
    NSString *urlAsString;
    if ([postFilterType isEqualToString:@"discoverfollowing"])
        urlAsString = GETAPILINK(@"postwebs/DiscoverPostsFollowing/");
    else if([postFilterType isEqualToString:@"top"])
        urlAsString = GETAPILINK(@"postwebs/TopPosts/");
    else if ([postFilterType isEqualToString:@"nearby"])
        urlAsString = GETAPILINK(@"postwebs/NearestPosts/");
    else
        urlAsString = GETAPILINK(@"postwebs/DiscoverPosts/");
    
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&post_filter=%@",postFilterType]];
    
    if ([postFilterType isEqualToString:@"nearby"])
    {
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&startlat=%@",str_latitude]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&startlon=%@",str_longitude]];
    }
    NSString *properlyEscapedURL = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:properlyEscapedURL];
    
    
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
        error = nil;
        id jsonObject = [NSJSONSerialization
                         JSONObjectWithData:data
                         options:NSJSONReadingAllowFragments
                         error:&error];
        if (jsonObject != nil && error == nil)
        {
            if ([jsonObject isKindOfClass:[NSDictionary class]])
            {
                NSLog(@"Dict...:%@",jsonObject);
            }
            else if ([jsonObject isKindOfClass:[NSArray class]])
            {
                NSLog(@"array...:%@",jsonObject);
            }
            NSLog(@"Successfully deserialized...:%@",jsonObject);
            
            memberUserIdArr = (NSMutableArray *)[jsonObject valueForKey:@"post_owner_user_id"];
            // no of like for the post array
            totalLike4Post =  (NSMutableArray *)[jsonObject valueForKey:@"total_like"];
            totalDisLike4Post =  (NSMutableArray *)[jsonObject valueForKey:@"total_dislike"];
            postMediaFileArr = (NSMutableArray *)[jsonObject valueForKey:@"post_mediafile"];
            postTitleArr = (NSMutableArray *)[jsonObject valueForKey:@"post_title"];
            postTimeArr = (NSMutableArray *)[jsonObject valueForKey:@"post_date"];
            postMediaTypeArr = (NSMutableArray *)[jsonObject valueForKey:@"mediatype"];
            hashTagArr = (NSMutableArray *)[jsonObject valueForKey:@"hash_tag"];
			thumbnailVideoArr = (NSMutableArray *)[jsonObject valueForKey:@"media_type_file"];
            isbtn_PostLikeSelected[[totalLike4Post count]] = NO;
        }
        else if (error != nil)
        {
            NSLog(@"An error happened while deserializing the JSON data.");
        }
    }
    else if ([data length] == 0 && error == nil)
	{
        NSLog(@"Nothing was downloaded.");
    }
    else if (error != nil){
        NSLog(@"Error happened = %@", error);
    }
    NSLog(@"HashTag Type : %@",hashTagArr);
}


#pragma mark - Collection View
// Collection View Delegate Methods
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (isFiltered == YES)
    {
        return [filteredBragger count];
    }
    else
    {
        return [postTitleArr count];
    }
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	
    MADiscoverBraggerCustomCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CELL" forIndexPath:indexPath];
    if (isFiltered == NO)
    {
		if ([[postTitleArr objectAtIndex:indexPath.row] isEqual:[NSNull null]])
			cell.lbl_PostTitle.text = @"";
		else
	        cell.lbl_PostTitle.text = (NSString*)[postTitleArr objectAtIndex:indexPath.row];
		
		if ([[postTimeArr objectAtIndex:indexPath.row] isEqual:[NSNull null]])
			cell.lbl_PostedTime.text = @"";
		else
	        cell.lbl_PostedTime.text = [MASingleton getCommentTime:(NSString*)[postTimeArr objectAtIndex:indexPath.row]];
        cell.lbl_ShowReBragCount.text = @"0";
        if ([[totalLike4Post objectAtIndex:indexPath.row] isEqual:[NSNull null]])
            cell.lbl_ShowLikeCount.text = @"0";
        else
            cell.lbl_ShowLikeCount.text = (NSString*)[totalLike4Post objectAtIndex:indexPath.row];
        
        if ([[totalDisLike4Post objectAtIndex:indexPath.row] isEqual:[NSNull null]])
            cell.lbl_ShowDisLikeCount.text = @"0";
        else
            cell.lbl_ShowDisLikeCount.text = (NSString*)[totalLike4Post objectAtIndex:indexPath.row];
       
        //Bragger Post Media
        
        if ([[postMediaFileArr objectAtIndex:indexPath.row] isEqual:[NSNull null]])
        {
            cell.img_FromPostMediaFile.image = [UIImage imageNamed:@"posted_Text1.png"];
        }
        else if ([[postMediaFileArr objectAtIndex:indexPath.row] isEqualToString:@"invalid file"])
        {
            cell.img_FromPostMediaFile.image = [UIImage imageNamed:@"beautiful-sea-view-wallpaper.jpg"];
        }
        else
        {
            
            if ([(NSString *)[postMediaTypeArr objectAtIndex:indexPath.row] isEqualToString:@"audio"])
            {
                cell.img_FromPostMediaFile.image = [UIImage imageNamed:@"posted_Audio.png"];
                
            }
            else if ([(NSString *)[postMediaTypeArr objectAtIndex:indexPath.row] isEqualToString:@"video"])
            {
				NSString *str_PostImageURL = [NSString stringWithFormat:@"%@",[thumbnailVideoArr objectAtIndex:indexPath.row]];
				NSURL *url_PostImage = [NSURL URLWithString:str_PostImageURL];
				
				dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
				dispatch_async(q, ^{
					/* Fetch the image from the server... */
					NSData *data_PostImage = [NSData dataWithContentsOfURL:url_PostImage];
					UIImage *img_PostImage = [[UIImage alloc] initWithData:data_PostImage];
					//                UIImageWriteToSavedPhotosAlbum(img_PostImage, self, nil, nil);
					dispatch_async(dispatch_get_main_queue(), ^{
						cell.img_FromPostMediaFile.image = img_PostImage;
//						UILabel *tapToPlayVid =  [[UILabel alloc]initWithFrame:CGRectMake(30, 75-50, 70, 30)];
//						tapToPlayVid.text = @"Tap to Play video";
//						tapToPlayVid.font = [UIFont systemFontOfSize:8.0];
//						tapToPlayVid.textColor = [UIColor blackColor];
////						tapToPlayVid.backgroundColor = [UIColor redColor];
//						[cell addSubview:tapToPlayVid];
						

					});
				});

               
            }
            else if([(NSString *)[postMediaTypeArr objectAtIndex:indexPath.row] isEqualToString:@"photo"])
            {
            
            NSString *str_PostImageURL = [NSString stringWithFormat:@"%@",[postMediaFileArr objectAtIndex:indexPath.row]];
            NSURL *url_PostImage = [NSURL URLWithString:str_PostImageURL];
            
            dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
            dispatch_async(q, ^{
                /* Fetch the image from the server... */
                NSData *data_PostImage = [NSData dataWithContentsOfURL:url_PostImage];
                UIImage *img_PostImage = [[UIImage alloc] initWithData:data_PostImage];
                dispatch_async(dispatch_get_main_queue(), ^{
                    /* This is the main thread again, where we set the tableView's image to
                     be what we just fetched. */
                    cell.img_FromPostMediaFile.image = img_PostImage;
                });
            });
            }
        }
        cell.btn_GoToBraggersProfile.tag = indexPath.row;
        [cell.btn_GoToBraggersProfile addTarget:self action:@selector(act_BraggerProfile:) forControlEvents:UIControlEventTouchUpInside];
    }
	else
    {
        
        int indexValue = [(NSNumber *)[filteredBraggerIndex objectAtIndex:indexPath.row] intValue];
        
        
        cell.lbl_PostTitle.text = (NSString*)[postTitleArr objectAtIndex:indexValue];
		
		if ([[postTimeArr objectAtIndex:indexValue] isEqual:[NSNull null]])
			cell.lbl_PostedTime.text = @"";
		else
        cell.lbl_PostedTime.text = [MASingleton getCommentTime:(NSString*)[postTimeArr objectAtIndex:indexValue]];
        cell.lbl_ShowReBragCount.text = @"0";
        
        
        
        if ([[totalLike4Post objectAtIndex:indexValue] isEqual:[NSNull null]])
            cell.lbl_ShowLikeCount.text = @"0";
        else
            cell.lbl_ShowLikeCount.text = (NSString*)[totalLike4Post objectAtIndex:indexValue];
        
        if ([[totalDisLike4Post objectAtIndex:indexValue] isEqual:[NSNull null]])
            cell.lbl_ShowDisLikeCount.text = @"0";
        else
            cell.lbl_ShowDisLikeCount.text = (NSString*)[totalLike4Post objectAtIndex:indexValue];
        //Bragger Post Media
        
        if ([[postMediaFileArr objectAtIndex:indexValue] isEqual:[NSNull null]])
        {
            cell.img_FromPostMediaFile.image = [UIImage imageNamed:@"posted_Text1.png"];
        }
        else if ([[postMediaFileArr objectAtIndex:indexValue] isEqualToString:@"invalid file"])
        {
            cell.img_FromPostMediaFile.image = [UIImage imageNamed:@"beautiful-sea-view-wallpaper.jpg"];
        }
        else
        {
            if ([(NSString *)[postMediaTypeArr objectAtIndex:indexValue] isEqualToString:@"audio"])
            {
                cell.img_FromPostMediaFile.image = [UIImage imageNamed:@"posted_Audio.png"];
                
            }
            else if ([(NSString *)[postMediaTypeArr objectAtIndex:indexValue] isEqualToString:@"video"])
            {
				cell.img_FromPostMediaFile.image = [UIImage imageNamed:@"posted_Video1.png"];
				NSString *str_PostImageURL = [NSString stringWithFormat:@"%@",[thumbnailVideoArr objectAtIndex:indexValue]];
				NSURL *url_PostImage = [NSURL URLWithString:str_PostImageURL];
				
				dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
				dispatch_async(q, ^{
					/* Fetch the image from the server... */
					NSData *data_PostImage = [NSData dataWithContentsOfURL:url_PostImage];
					UIImage *img_PostImage = [[UIImage alloc] initWithData:data_PostImage];
					//                UIImageWriteToSavedPhotosAlbum(img_PostImage, self, nil, nil);
					dispatch_async(dispatch_get_main_queue(), ^{
						cell.img_FromPostMediaFile.image = img_PostImage;
					});
				});

                
            }
            else if([(NSString *)[postMediaTypeArr objectAtIndex:indexValue] isEqualToString:@"photo"])
            {
                cell.img_FromPostMediaFile.image = [UIImage imageNamed:@"posted_photo1.png"];
                NSString *str_PostImageURL = [NSString stringWithFormat:@"%@",[postMediaFileArr objectAtIndex:indexValue]];
                NSURL *url_PostImage = [NSURL URLWithString:str_PostImageURL];
                
                dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                dispatch_async(q, ^{
                    /* Fetch the image from the server... */
                    NSData *data_PostImage = [NSData dataWithContentsOfURL:url_PostImage];
                    UIImage *img_PostImage = [[UIImage alloc] initWithData:data_PostImage];
                    dispatch_async(dispatch_get_main_queue(), ^{
						/* This is the main thread again, where we set the tableView's image to
                         be what we just fetched. */
						cell.img_FromPostMediaFile.image = img_PostImage;
    
                    });
                });
            }

            
        }
        cell.btn_GoToBraggersProfile.tag = indexValue;
        [cell.btn_GoToBraggersProfile addTarget:self action:@selector(act_BraggerProfile:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return cell;
}

- (void) gotoProfile:(UIButton*)sender
{
    MABraggerProfileViewController *obj_BraggerProfile;
	obj_BraggerProfile = [[MABraggerProfileViewController alloc] initWithNibName:@"MABraggerProfileViewController" bundle:nil];
	obj_BraggerProfile.str_SelectedUserId = (NSString*)[memberUserIdArr objectAtIndex:sender.tag];
    [self presentViewController:obj_BraggerProfile animated:YES completion:nil];
}

// Go to Braggers Profile Screen
- (void)act_BraggerProfile:(UIButton*)sender
{
    [mainSearchBar resignFirstResponder];
    
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [self.view bringSubviewToFront:HUD];
    HUD.dimBackground = YES;
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    // Show the HUD while the provided method executes in a new thread
    [HUD showWhileExecuting:@selector(gotoProfile:) onTarget:self withObject:sender animated:YES];
}

#pragma mark - UISearchBar Delegate Methods
// Search Bar Delegates
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    

    if (searchText.length == 0)
    {
        //Set Our Boolean Flag
        isFiltered = NO;
    }
    else
    {
        //Set Our Boolean Flag
        isFiltered = YES;
        //Alloc and Init our Filtered Data
        filteredBragger = [[NSMutableArray alloc] init];
        filteredBraggerIndex = [[NSMutableArray alloc] init];
        //Fast Enumeration
        for (int i = 0; i<[hashTagArr count]; i++)
        {
            if ([[hashTagArr objectAtIndex:i] isEqual:[NSNull null]])
            {
//                i++;
                NSLog(@"Search Test is Null");
            }
            else
            {
                NSString *titleName = (NSString*)[hashTagArr objectAtIndex:i];
                NSRange titleNameRange = [titleName rangeOfString:searchText options:NSCaseInsensitiveSearch];
                if (titleNameRange.location != NSNotFound)
                {
                    [filteredBragger addObject:titleName];
                    [filteredBraggerIndex addObject:[NSNumber numberWithInt: i]];
                }
                NSLog(@"Filtered Bragger : %@ at Index : %@",filteredBragger,filteredBraggerIndex);
            }
            
        }
        
    }
    
    //Reload Our Collection View
    [coll_DiscoverBragger reloadData];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [mainSearchBar resignFirstResponder];
	
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [mainSearchBar resignFirstResponder];
	[coll_DiscoverBragger reloadData];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)search
{
    UITextField *searchBarTextField = nil;
    for (UIView *mainview in search.subviews) {
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1) {
            if ([mainview isKindOfClass:[UITextField class]]) {
                searchBarTextField = (UITextField *)mainview;
                break;
            }
        }
        for (UIView *subview in mainview.subviews) {
            if ([subview isKindOfClass:[UITextField class]]) {
                searchBarTextField = (UITextField *)subview;
                break;
            }
        }
    }
    searchBarTextField.enablesReturnKeyAutomatically = NO;
	[coll_DiscoverBragger reloadData];
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







