//
//  MABraggingStreamViewController.m
//  Bragger
//
//  Created by GaoShen on 2/2/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)
#import "MABraggingStreamViewController.h"
#import "MABraggerProfileViewController.h"
#import "MADiscoverBraggerViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import "MAShareBragViewController.h"
#import "MACommentsViewController.h"
#import "MABraggerLoginViewController.h"
#import "MASingleton.h"
#import "MASettingsViewController.h"
#import "Reachability.h"
#import "ActivityIndicator.h"
#import "Constant.h"

int g_isCommentedRow = -1;
BOOL isCommentIsPosted[0];

@interface MABraggingStreamViewController ()
{
    AVAudioPlayer *player;
    NSString *userId;
    NSString *sessionId;
    NSString *str_latitude;
    NSString *str_longitude;
    NSMutableArray *fullNameArr;
    NSMutableArray *nickNameArr;
    NSMutableArray *userImageArr;
    NSMutableArray *userLocationArr;
    NSMutableArray *locationArr;
    NSMutableArray *memberUserIdArr;
    NSMutableArray *totalDisLike4Post;
    NSMutableArray *postIdArr;
    NSMutableArray *postMediaFileArr;
    NSMutableArray *totalLike4Post;
    NSMutableArray *isFollowingFlagArr;
    NSMutableArray *postTitleArr;
    NSMutableArray *postTimeArr;
    NSMutableArray *totalCommentArr;
    NSMutableArray *totalRebrag4Post;
    NSMutableArray *postMediaTypeArr;
    NSMutableArray *isLikePostArr;
    NSMutableArray *isDislikePostArr;
    NSMutableArray *isRebragArr;
    NSMutableArray *isHashTagArr;
    NSMutableData *_responseData;
	NSMutableArray *thumbnailVideoArr;
	
	
	
    int int_SelectedIndexFollower;
    int intTemp_SelectedIndexFollower;
    NSString *path;
    CLLocationManager *locationManager;
    CLLocation *currentLocation;
    NSString *currentCity;
    NSString *countTotalComments;
    BOOL isVideoImage;
	Reachability *reachability;
	UIAlertView *alert4Connectivity;
	BOOL isAlertShowing;

}


@end

@implementation MABraggingStreamViewController

@synthesize seg_BraggerStreamSegment,REGUSER,customCell,FrameImage, scrollView;
@synthesize movieController,btn_ExitFullScreen,img_FullScreen,lbl_FollowersStatus;
#pragma mark - init
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        // Custom initialization
		//Spam, Inappropriate, Bullying, Block Author
//		UIAlertView *alert = [[UIAlertView alloc]
//							  initWithTitle:@"What's wrong with this brag?"
//                              message:nil
//							  delegate:self
//							  cancelButtonTitle:@"Cancel"
//							  otherButtonTitles:@"Spam", @"Inappropriate",@"Bullying",@"Block Author", nil];
//		[alert show];
//		
    }
    
    [self act_ChangeSegment:nil];
    
    return self;
}

-(void) viewWillAppear:(BOOL)animated
{
    if (g_isCommentedRow != -1)
    {
        NSString* oldcomments = [totalCommentArr objectAtIndex:g_isCommentedRow];
        NSString* newcomments = [NSString stringWithFormat:@"%d comments", oldcomments.intValue+1];
        
        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:g_isCommentedRow inSection:0];
        MABraggingStreamCustomCell *cell = (MABraggingStreamCustomCell *)[tbl_Braggers cellForRowAtIndexPath:rowToReload];
        
        [cell.btn_Comment setTitle:newcomments forState:UIControlStateNormal];
    }
    
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
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    //[tbl_Braggers addSubview:refreshControl];
    locationManager = [[CLLocationManager alloc]init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_id"];
    str_latitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"latitude"];
    str_longitude = [[NSUserDefaults standardUserDefaults] objectForKey:@"longtitude"];
    
    NSLog(@"userId : %@ , sessionId : %@",userId,sessionId);
    
    tbl_Braggers.rowHeight = 423;
    displayedCount = 5;
    int totaltableheight = 423*displayedCount+50;
    tbl_Braggers =[[UITableView alloc] initWithFrame:CGRectMake(0, 4, 299, totaltableheight) style:UITableViewStylePlain];
    tbl_Braggers.scrollEnabled = NO;
    tbl_Braggers.delegate = self;
    tbl_Braggers.dataSource = self;
    tbl_Braggers.backgroundView = nil;
    tbl_Braggers.separatorStyle = UITableViewCellSeparatorStyleNone;
    [scrollView addSubview:tbl_Braggers];
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, totaltableheight)];
    [scrollView addSubview:refreshControl];
    
    int_SelectedIndexFollower = -1;
    intTemp_SelectedIndexFollower = -2;
    
    btn_ExitFullScreen.hidden = YES;
    img_FullScreen.hidden = YES;
    lbl_FollowersStatus.hidden = YES;
    
    UIFont *font = [UIFont systemFontOfSize:11.0f];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:font
                                                           forKey:NSFontAttributeName];
    [seg_BraggerStreamSegment setTitleTextAttributes:attributes
                                            forState:UIControlStateNormal];
    [[UISegmentedControl appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                             [UIColor colorWithRed:63.0/255.0 green:170.0/255.0 blue:237.0/255.0 alpha:1],UITextAttributeTextColor, nil]
                                                   forState:UIControlStateSelected];
    seg_BraggerStreamSegment.selectedSegmentIndex = 1;
	
  /*
    if ([MABraggerLoginViewController isBragAnnIsSelected])
        [self DiscoverPostAnonymous:@"top" postLocation:nil];
    else
        [self DiscoverPostToserver:@"top"];
    */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) onSwitchFilters
{
    switch (seg_BraggerStreamSegment.selectedSegmentIndex)
    {
        case 0:
            if ([MABraggerLoginViewController isBragAnnIsSelected])
                [self DiscoverPostAnonymous:@"top" postLocation:nil];
            else
                
                [self DiscoverPostToserver:@"top"];
            [tbl_Braggers reloadData];
            lbl_FollowersStatus.hidden = YES;
            break;
        case 1:
            if ([MABraggerLoginViewController isBragAnnIsSelected])
                [self DiscoverPostAnonymous:@"latest" postLocation:nil];
            else
                [self DiscoverPostToserver:@"latest"];
            [tbl_Braggers reloadData];
            lbl_FollowersStatus.hidden = YES;
            break;
        case 2:
            if ([MABraggerLoginViewController isBragAnnIsSelected])
                [self DiscoverPostAnonymous:@"nearby" postLocation:[[MASingleton sharedManager] getLocation]];
            else
                [self DiscoverPostToserver:@"nearby"];
            [tbl_Braggers reloadData];
            lbl_FollowersStatus.hidden = YES;
            break;
        case 3:
            if (![MABraggerLoginViewController isBragAnnIsSelected])
            {
                [self DiscoverPostToserver:@"discoverfollowing"];
                if (fullNameArr == nil )
                {
                    lbl_FollowersStatus.hidden = NO;
                    lbl_FollowersStatus.text = @"Currently, there are no brags from your followers";
                    [tbl_Braggers reloadData];
                }
                else
                {
                    lbl_FollowersStatus.hidden = YES;
                    [tbl_Braggers reloadData];
                }
            }
            break;
        default:
            break;
            
    }
}

#pragma mark - Segmented Control (Top Braggers, Latest Braggers)

// Select SegmentControl To See Top,latest, nearBy Braggers
- (IBAction)act_ChangeSegment:(id)sender
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

#pragma mark - discover post
// For Getting Braggers all Data - Top, NearBy, Latest, DiscoverFollowing
-(void)DiscoverPostToserver:(NSString *)postFilterType
{
    
    NSString *urlAsString;
    
    [self resetScrollView];
    
    if ([postFilterType isEqualToString:@"discoverfollowing"])
    {
        urlAsString = GETAPILINK(@"postwebs/DiscoverPostsFollowing/");
    }
    else if([postFilterType isEqualToString:@"top"])
        urlAsString = GETAPILINK(@"postwebs/TopPosts/");
    
    else if ([postFilterType isEqualToString:@"nearby"])
        urlAsString = GETAPILINK(@"postwebs/NearestPosts/");
    else
        urlAsString = GETAPILINK(@"postwebs/DiscoverPosts/");
    
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&post_filter=%@",postFilterType]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&offset=%d",0]];
    
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
            //NSLog(@"Json Object : %@",jsonObject);
            
            fullNameArr = (NSMutableArray *)[jsonObject  valueForKey:@"fullname"];
            // Update by sabari on 21/Mar/14
            nickNameArr = (NSMutableArray *)[jsonObject valueForKey:@"nickname"];
            userImageArr =  (NSMutableArray *)[jsonObject valueForKey:@"user_image"];
            locationArr =  (NSMutableArray *)[jsonObject valueForKey:@"post_location"];
            userLocationArr = (NSMutableArray *)[jsonObject valueForKey:@"user_location"];
            memberUserIdArr = (NSMutableArray *)[jsonObject valueForKey:@"post_owner_user_id"];
            totalLike4Post =  (NSMutableArray *)[jsonObject valueForKey:@"total_like"];
            totalDisLike4Post =  (NSMutableArray *)[jsonObject valueForKey:@"total_dislike"];
            postMediaFileArr = (NSMutableArray *)[jsonObject valueForKey:@"post_mediafile"];
            postIdArr =  (NSMutableArray *)[jsonObject valueForKey:@"post_id"];
            
            postTitleArr = (NSMutableArray *)[jsonObject valueForKey:@"post_title"];
            totalCommentArr = (NSMutableArray *)[jsonObject valueForKey:@"total_comment"];
            postTimeArr = (NSMutableArray *)[jsonObject valueForKey:@"post_date"];
            totalRebrag4Post = (NSMutableArray *)[jsonObject valueForKey:@"total_shared"];
            postMediaTypeArr = (NSMutableArray *)[jsonObject valueForKey:@"mediatype"];
            isLikePostArr = (NSMutableArray *)[jsonObject valueForKey:@"like_flag"];
            isDislikePostArr = (NSMutableArray *)[jsonObject valueForKey:@"dislike_flag"];
            isRebragArr = (NSMutableArray *)[jsonObject valueForKey:@"shared_flag"];
            isHashTagArr = (NSMutableArray *)[jsonObject valueForKey:@"hash_tag"];
			thumbnailVideoArr = (NSMutableArray *)[jsonObject valueForKey:@"media_type_file"];
			
	        if ([postFilterType isEqualToString:@"discoverfollowing"])
                isFollowingFlagArr = nil;
            else
                isFollowingFlagArr = (NSMutableArray *)[jsonObject valueForKey:@"following_flag"];
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
    
}

#pragma mark - TextField KeyBoard Animation
-(IBAction)HdKeyboard:(id)sender
{
    
    
}

// TextView Animation and Delegates
- (void) animateTextView:(BOOL) up
{
    const int movementDistance =140.0; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    int movement= movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if ([MABraggerLoginViewController isBragAnnIsSelected])
        return NO;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextView : YES];
    
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    
    [self postCommentToServer:textField.text postId:textField.tag];
    [self  animateTextView :NO];
    textField.text = nil;
    
}

- (BOOL) textFieldShouldReturn:(UITextField *)theTextField
{
	
	[theTextField resignFirstResponder];
    return YES;
}

- (void) viewBragger
{
    MADiscoverBraggerViewController *obj_AboutVC;
    obj_AboutVC = [[MADiscoverBraggerViewController alloc] initWithNibName:@"MADiscoverBraggerViewController" bundle:nil];
    [self presentViewController:obj_AboutVC animated:YES completion:nil];
    
}

#pragma mark - Bragging, Braggers & ShareBrag (TabBar)

- (IBAction)act_Bragging:(id)sender
{
    
}

// Go To DiscoverBraggers Screen
- (IBAction)act_Braggers:(id)sender
{
    if ([MABraggerLoginViewController isBragAnnIsSelected])
    {
        [self showSignInAlert];
    }
    else
    {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        [self.view bringSubviewToFront:HUD];
        HUD.dimBackground = YES;
        // Regiser for HUD callbacks so we can remove it from the window at the right time
        HUD.delegate = self;
        // Show the HUD while the provided method executes in a new thread
        [HUD showWhileExecuting:@selector(viewBragger) onTarget:self withObject:Nil animated:YES];
    }
}

// Go To Post Sharing Screen
- (IBAction)act_ShareBrag:(id)sender
{
    if ([MABraggerLoginViewController isBragAnnIsSelected])
    {
        [self showSignInAlert];
    }
    else
    {
        
        MAShareBragViewController *obj_AboutVC;
        obj_AboutVC = [[MAShareBragViewController alloc] initWithNibName:@"MAShareBragViewController" bundle:nil];
        obj_AboutVC.view1=0;
		[self presentPopupViewController:obj_AboutVC animationType:MJPopupViewAnimationFade];

		
    }
    
}

#pragma mark - Table View
// TableView Delegates
- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [fullNameArr count];
    //return displayedCount;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	CGFloat ht;
	if ([[postMediaTypeArr objectAtIndex:indexPath.row] isEqualToString:@"not"])
		ht=320;
	else
		ht = 436;//orginal- 407
	return ht;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MABraggingStreamCustomCell *cell = (MABraggingStreamCustomCell*) [tableView dequeueReusableCellWithIdentifier:[MABraggingStreamCustomCell reuseIdentifier]];
    
    if ([postMediaFileArr objectAtIndex:0]==nil)
    {
        UIAlertView *alert_InternetConnection = [[UIAlertView alloc] initWithTitle:@"Bragger" message:@"Unable to Connect Server" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert_InternetConnection show];
    }
    else
    {

        if(cell == nil)
        {
    //        [[NSBundle mainBundle] loadNibNamed:@"MABraggingStreamCustomCell" owner:self options:nil];
            NSLog(@"%@",[postMediaTypeArr objectAtIndex:indexPath.row]);
            if ([[postMediaTypeArr objectAtIndex:indexPath.row] isEqualToString:@"not"])
                cell = [[MABraggingStreamCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MABraggingStreamCustomCell2"];
            else
              cell = [[MABraggingStreamCustomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MABraggingStreamCustomCell"];
    //        cell = customCell;
    //        customCell = nil;
        }
		
		NSLog(@"%f%f",cell.contentView.frame.size.height,cell.contentView.frame.origin.y);
		
        UIView* separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 299, 5)];/// change size as you need.
        separatorLineView.backgroundColor = [UIColor grayColor];// you can also put image here
        [cell.contentView addSubview:separatorLineView];
        
        UIImageView *separatorImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 299, 5)];
        separatorImage.image = [UIImage imageNamed:@"Separator_Line1.png"];
        [separatorLineView addSubview:separatorImage];
        cell.img_ToUserImage.layer.cornerRadius = 60/2;
        cell.img_ToUserImage.layer.masksToBounds = YES;
        //Bragger Name
        cell.btn_BraggerName.tag = indexPath.row;
        if ([[nickNameArr objectAtIndex:indexPath.row] isEqual:[NSNull null]])
        {
            [cell.btn_BraggerName setTitle:[NSString stringWithFormat:@"null"] forState:UIControlStateNormal];
        }
        else
        {
            [cell.btn_BraggerName setTitle:(NSString *)[nickNameArr objectAtIndex:indexPath.row] forState:UIControlStateNormal];
            [cell.btn_BraggerName setTitle:(NSString *)[nickNameArr objectAtIndex:indexPath.row] forState:UIControlStateHighlighted];
        }
        
        //Bragger UserImage
        if ([[userImageArr objectAtIndex:indexPath.row] isEqual:[NSNull null]])
        {
            cell.img_ToUserImage.image = [UIImage imageNamed:@"default_profileUserImage.png"];
        }
        else if ([[userImageArr objectAtIndex:indexPath.row] isEqualToString:@"invalid file"])
        {
            cell.img_ToUserImage.image = [UIImage imageNamed:@"default_profileUserImage.png"];
        }
        else
        {
            cell.img_ToUserImage.image = [UIImage imageNamed:@"default_profileUserImage.png"];
            dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,  0ul);
            dispatch_async(queue, ^{
                NSString *str_ImageUrl = [NSString stringWithFormat:@"%@",[userImageArr objectAtIndex:indexPath.row]];
                NSURL *url_Image = [NSURL URLWithString:str_ImageUrl];
                NSData *imgData = [NSData dataWithContentsOfURL:url_Image];
                if (imgData)
                {
                    UIImage *image = [UIImage imageWithData:imgData];
                    if (image) {
                        dispatch_async(dispatch_get_main_queue(), ^
                                       {
                                           cell.img_ToUserImage.image = image;
                                       });
                    }
                }
            });
            
        }
        
        //Update By Sabari March - 22
        //Bragger Location
      
        if ([[locationArr objectAtIndex:indexPath.row] isEqual:[NSNull null]] || [[locationArr objectAtIndex:indexPath.row] isEqualToString:@"(null)"])
        {
            cell.lbl_LocationLabel.text = [NSString stringWithFormat:@" "];
            cell.img_PinLocation.hidden = YES;
        }
        else
        {
            
            cell.lbl_LocationLabel.text = (NSString *)[locationArr objectAtIndex:indexPath.row];
        }
        
       
        cell.btn_imgFromPostMediaFile.tag = indexPath.row;
        
        if ([[postMediaFileArr objectAtIndex:indexPath.row] isEqual:[NSNull null]])
        {
            
    //        UILabel  * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 95, 299, 198)];
    //        label.backgroundColor = [UIColor clearColor];
    //        label.textColor=[UIColor blackColor];
    //        label.numberOfLines=0;
    //        if (![[postTitleArr objectAtIndex:indexPath.row] isEqual:[NSNull null]])
    //        {
    //            label.text = (NSString *)[postTitleArr objectAtIndex:indexPath.row];
    //        }
    //		
    //        [label sizeToFit];
    //        [cell addSubview:label];
    //
            if ([[postTitleArr objectAtIndex:indexPath.row] isEqual:[NSNull null]])
                cell.lbl_WritePost.text = @"";
            else
            cell.lbl_WritePost.text = (NSString *)[postTitleArr objectAtIndex:indexPath.row];

    //        cell.lbl_TitleLabel.text = @"";
            cell.btn_LikeInVw.backgroundColor = [UIColor lightGrayColor];
            cell.btn_RebragVw.backgroundColor = [UIColor lightGrayColor];
            cell.btn_ShowOffVw.backgroundColor = [UIColor lightGrayColor];
        }
        else if ([[postMediaFileArr objectAtIndex:indexPath.row] isEqualToString:@"invalid file"])
        {
            [cell.btn_imgFromPostMediaFile setImage:[UIImage imageNamed:@"beautiful-sea-view-wallpaper.jpg"] forState:UIControlStateNormal];
        }
        else
        {
            
            if ([(NSString *)[postMediaTypeArr objectAtIndex:indexPath.row] isEqualToString:@"audio"])
            {
                cell.img_FromPostMediaFile.image = [UIImage imageNamed:@"posted_Audio.png"];
                cell.btn_imgFromPostMediaFile.userInteractionEnabled = YES;
                [cell.btn_imgFromPostMediaFile addTarget:self action:@selector(act_GoToAudioPlayer:) forControlEvents:UIControlEventTouchUpInside];
                cell.lbl_TitleLabel.text = (NSString *)[postTitleArr objectAtIndex:indexPath.row];
                
            }
            else if ([(NSString *)[postMediaTypeArr objectAtIndex:indexPath.row] isEqualToString:@"video"])
            {
    //            NSURL *videoURl = [NSURL URLWithString:[postMediaFileArr objectAtIndex:indexPath.row]];
    //			AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURl options:nil];
    //			AVAssetImageGenerator *generate = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    //			generate.appliesPreferredTrackTransform = YES;
    //			NSError *err = NULL;
    //			CMTime time = CMTimeMake(1, 60);
    //			CGImageRef imgRef = [generate copyCGImageAtTime:time actualTime:NULL error:&err];
    //			
    //			UIImage *img = [[UIImage alloc] initWithCGImage:imgRef];
    //			[YourImageView setImage:img];
                cell.lbl_TitleLabel.text = (NSString *)[postTitleArr objectAtIndex:indexPath.row];

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
                    });
                });

                UILabel *tapToPlayVid =  [[UILabel alloc]initWithFrame:CGRectMake(75, 200, 200, 30)];
                tapToPlayVid.text = @"Tap to Play video";
                tapToPlayVid.font = [UIFont systemFontOfSize:18.0];
                tapToPlayVid.textColor = [UIColor blackColor];
                [cell addSubview:tapToPlayVid];

                
    //            cell.img_FromPostMediaFile.image = [UIImage imageNamed:@"posted_Video1.png"];
                
                [cell.btn_imgFromPostMediaFile addTarget:self action:@selector(act_GoToVideoPlayer:) forControlEvents:UIControlEventTouchUpInside];

            }
            else if([(NSString *)[postMediaTypeArr objectAtIndex:indexPath.row] isEqualToString:@"photo"])
            {
                cell.btn_imgFromPostMediaFile.userInteractionEnabled = YES;
                cell.lbl_TitleLabel.text = (NSString *)[postTitleArr objectAtIndex:indexPath.row];
                NSString *str_PostImageURL = [NSString stringWithFormat:@"%@",[postMediaFileArr objectAtIndex:indexPath.row]];
                NSURL *url_PostImage = [NSURL URLWithString:str_PostImageURL];
                //[cell.btn_imgFromPostMediaFile addTarget:self action:@selector(act_GoToImageViewer:) forControlEvents:UIControlEventTouchUpInside];
                
                dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
                dispatch_async(q, ^{
                    /* Fetch the image from the server... */
                    NSData *data_PostImage = [NSData dataWithContentsOfURL:url_PostImage];
                    UIImage *img_PostImage = [[UIImage alloc] initWithData:data_PostImage];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        cell.img_FromPostMediaFile.image = img_PostImage;
                    });
                });
               
            }
            else
            {
                UILabel  * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 280, 120)];
                label.backgroundColor = [UIColor clearColor];
                label.textColor=[UIColor blackColor];
                label.text = (NSString *)[postTitleArr objectAtIndex:indexPath.row];
                [label sizeToFit];
                if (label.numberOfLines == 1)
                {
                    cell.img_FromPostMediaFile = [[UIImageView alloc]initWithFrame:CGRectMake(0, 95, 299, 120)];
                }
                else if(label.numberOfLines == 2)
                {
                    cell.img_FromPostMediaFile = [[UIImageView alloc]initWithFrame:CGRectMake(0, 95, 299, 150)];
                }
                else
                {
                    cell.img_FromPostMediaFile = [[UIImageView alloc]initWithFrame:CGRectMake(0, 95, 299, 180)];
                }

                [cell.img_FromPostMediaFile addSubview:label];
                cell.lbl_TitleLabel.text = @"";
                
            }
            
        }
        NSLog(@"media file:%@",postMediaFileArr);
        // like
        cell.btn_PostLike.tag = indexPath.row;
        if ([[totalLike4Post objectAtIndex:indexPath.row] isEqual:[NSNull null]])
            cell.lbl_TotalLike4Post.text = @"0 Likes";
        else
        {
            cell.lbl_TotalLike4Post.text = [NSString stringWithFormat:@"%@ Likes",(NSString *)[totalLike4Post objectAtIndex:indexPath.row]];
            if ([(NSString *)[isLikePostArr objectAtIndex:indexPath.row] isEqualToString:@"yes"])
                [cell.btn_PostLike setImage:[UIImage imageNamed:@"bragger_Profile_Like_button_blue.png"] forState:UIControlStateNormal];
        }
        
        // Check Follow
        cell.btn_Follower.tag = indexPath.row;
        if (![(NSString *)[isFollowingFlagArr objectAtIndex:indexPath.row] isEqualToString:@"not following"])
        {
            [cell.btn_Follower setImage:[UIImage imageNamed:@"bragger_Profile_Unfollow_Button"] forState:UIControlStateNormal];
    //        cell.btn_Follower.userInteractionEnabled = NO;
        }
        
        if ([(NSString *)[memberUserIdArr objectAtIndex:indexPath.row] isEqual:userId])
        {
            cell.btn_Follower.hidden = YES;
            cell.btn_Rebrag.userInteractionEnabled = NO;
            cell.btn_RebragVw.userInteractionEnabled = NO;
            
        }
        
        // set post time
        if ([[postTimeArr objectAtIndex:indexPath.row] isEqual:[NSNull null]])
            cell.lbl_PostTime.text = @"";
        else
            cell.lbl_PostTime.text = [MASingleton  getCommentTime:(NSString *)[postTimeArr objectAtIndex:indexPath.row]];
        
        // set total dislike
        if ([[totalDisLike4Post objectAtIndex:indexPath.row] isEqual:[NSNull null]])
            cell.lbl_TotalShowOff4Post.text = @"0 Show-off's";
        else
        {
            
            cell.lbl_TotalShowOff4Post.text = [NSString stringWithFormat:@"%@ Show-off's",(NSString *)[totalDisLike4Post objectAtIndex:indexPath.row]];
            if ([(NSString *)[isDislikePostArr objectAtIndex:indexPath.row] isEqualToString:@"yes"])
                [cell.btn_ShowOff setImage:[UIImage imageNamed:@"bragger_Profile_Showoff_blue_button.png"] forState:UIControlStateNormal];
        }
        
        // set total share
        if ([[totalRebrag4Post objectAtIndex:indexPath.row] isEqual:[NSNull null]])
            cell.lbl_TotalReBrags4Post.text =@"0 Rebrags";
        else
        {
            cell.lbl_TotalReBrags4Post.text = [NSString stringWithFormat:@"%@ Rebrags",(NSString *)[totalRebrag4Post objectAtIndex:indexPath.row]];
            if ([(NSString *)[isRebragArr objectAtIndex:indexPath.row] isEqual:@"yes"])
                [cell.btn_Rebrag setImage:[UIImage imageNamed:@"bragger_Profile_Rebrags_blue_button.png"] forState:UIControlStateNormal];
            
        }
        
        // set total comments
        if ([[totalCommentArr objectAtIndex:indexPath.row] isEqual:[NSNull null]] || [[totalCommentArr objectAtIndex:indexPath.row] isEqualToString:@"(null)"])
            [cell.btn_Comment setTitle:@"0 Comments" forState:UIControlStateNormal];
        else
        {
            NSLog(@"%@",(NSString *)[totalCommentArr objectAtIndex:indexPath.row]);
            [cell.btn_Comment setTitle:[NSString stringWithFormat:@"%@ comments",(NSString *)[totalCommentArr objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
        }
        // text field
        //cell.txt_CommentBragText.tag = indexPath.row;
        
        // hash tag
        if ([[isHashTagArr objectAtIndex:indexPath.row] isEqual:[NSNull null]])
            cell.lbl_HashTag.text = @"";
        else
            cell.lbl_HashTag.text = (NSString *)[isHashTagArr objectAtIndex:indexPath.row];
        
        //check Comment
        // to set button tag
        cell.btn_Comment.tag = indexPath.row;
        cell.btn_ShowOff.tag = indexPath.row;
        cell.btn_Rebrag.tag = indexPath.row;
        cell.btn_LikeInVw.tag = indexPath.row;
        cell.btn_ShowOffVw.tag = indexPath.row;
        cell.btn_RebragVw.tag = indexPath.row;
        cell.btn_Flag.tag = indexPath.row;
        [cell.btn_Flag addTarget:self action:@selector(act_Flag:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_Follower addTarget:self action:@selector(act_AddFollower:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_PostLike addTarget:self action:@selector(act_LikePost:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_ShowOff addTarget:self action:@selector(act_DisLikePost:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_Comment addTarget:self action:@selector(act_Comment:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_BraggerName addTarget:self action:@selector(act_BraggerProfile:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_LikeInVw  addTarget:self action:@selector(act_LikePost:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_ShowOffVw addTarget:self action:@selector(act_DisLikePost:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_RebragVw addTarget:self action:@selector(act_Rebrag:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_Rebrag addTarget:self action:@selector(act_Rebrag:) forControlEvents:UIControlEventTouchUpInside];
        //cell.txt_CommentBragText.delegate=self;
    
    }
	return cell;
}




#pragma mark - follow

// Add the Follower
- (void)act_AddFollower:(UIButton*)sender
{
    if ([MABraggerLoginViewController isBragAnnIsSelected])
    {
        [self showSignInAlert];
    }
    else
    {
		if ([(NSString *)[isFollowingFlagArr objectAtIndex:sender.tag] isEqualToString:@"not following"])
		{
			
			NSString *urlAsString = GETAPILINK(@"memberwebs/AddFollowers/");
			
			urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];
			urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];
			urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&to_user_id=%@",[memberUserIdArr objectAtIndex:sender.tag]]];
			
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
				error = nil;
				id jsonObject = [NSJSONSerialization
								 JSONObjectWithData:data
								 options:NSJSONReadingAllowFragments
								 error:&error];
				if (jsonObject != nil && error == nil)
				{
					if ([jsonObject isKindOfClass:[NSDictionary class]])
					{
						NSDictionary *deserializedDictionary = jsonObject;
						NSLog(@"Deserialized JSON Dictionary = %@",
							  deserializedDictionary);
						
						if ([[deserializedDictionary objectForKey:@"jsonstatus" ] isEqualToString:@"fail"])
						{
							UIAlertView *alert_Follower = [[UIAlertView alloc] initWithTitle:@"Bragger" message:[deserializedDictionary valueForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
							[alert_Follower show];
						}
						
					}
				}
			}
		}
		else
		{
			NSString *urlAsString = GETAPILINK(@"memberwebs/UnFollow/");
			
			urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];
			urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];
			urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&to_user_id=%@",[memberUserIdArr objectAtIndex:sender.tag]]];
			
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
				error = nil;
				id jsonObject = [NSJSONSerialization
								 JSONObjectWithData:data
								 options:NSJSONReadingAllowFragments
								 error:&error];
				if (jsonObject != nil && error == nil)
				{
					if ([jsonObject isKindOfClass:[NSDictionary class]])
					{
						NSDictionary *deserializedDictionary = jsonObject;
						NSLog(@"Deserialized JSON Dictionary = %@",
							  deserializedDictionary);
						
						if ([[deserializedDictionary objectForKey:@"jsonstatus" ] isEqualToString:@"fail"])
						{
							UIAlertView *alert_Follower = [[UIAlertView alloc] initWithTitle:@"Bragger" message:[deserializedDictionary valueForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
							[alert_Follower show];
						}
						
					}
				}
			}

		}
        [self act_ChangeSegment:nil];
    }
}

#pragma mark - like ,dilike
// Like The Posts
- (void)act_LikePost:(UIButton *)sender
{
    
    if ([MABraggerLoginViewController isBragAnnIsSelected])
    {
        [self showSignInAlert];
    }
    else
        [self likeOrDislikePostServer:@"yes" postId:sender.tag];
    
}
// DisLike The Posts
- (void)act_DisLikePost:(UIButton *)sender
{
    if ([MABraggerLoginViewController isBragAnnIsSelected])
    {
        [self showSignInAlert];
    }
    else
        [self likeOrDislikePostServer:@"no" postId:sender.tag];
}

// Like or DisLike the Posts to server
-(void)likeOrDislikePostServer:(NSString *)likeOrDisLike postId:(int )postId
{
    NSString *urlAsString = GETAPILINK(@"postwebs/LikeDislikePost/");
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];
    
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&post_id=%@",[postIdArr objectAtIndex:postId]]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&like_dislike_status=%@",likeOrDisLike]];
    
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
                NSDictionary *deserializedDictionary = jsonObject;
                if ([[deserializedDictionary objectForKey:@"jsonstatus" ] isEqualToString:@"fail"])
                {
                    UIAlertView *alert_Follower = [[UIAlertView alloc] initWithTitle:@"Bragger" message:[deserializedDictionary valueForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert_Follower show];
                }
                else
                {
                    if ([likeOrDisLike isEqualToString:@"yes"])
                    {
                        NSString* oldlikes = [totalLike4Post objectAtIndex:postId];
                        int n = oldlikes.intValue;
                        NSString* newlikes = [NSString stringWithFormat:@"%d Likes", n+1];
                        
                        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:postId inSection:0];
                        MABraggingStreamCustomCell *cell = (MABraggingStreamCustomCell *)[tbl_Braggers cellForRowAtIndexPath:rowToReload];
                        cell.lbl_TotalLike4Post.text = newlikes;
                        [cell.btn_PostLike setImage:[UIImage imageNamed:@"bragger_Profile_Like_button_blue.png"] forState:UIControlStateNormal];

                    }
                    else//if ([likeOrDisLike isEqualToString:@"no"])
                    {
                        NSString* oldlikes = [totalDisLike4Post objectAtIndex:postId];
                        int n = oldlikes.intValue;
                        NSString* newlikes = [NSString stringWithFormat:@"%d Show-off's", n+1];
                        
                        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:postId inSection:0];
                        MABraggingStreamCustomCell *cell = (MABraggingStreamCustomCell *)[tbl_Braggers cellForRowAtIndexPath:rowToReload];
                        cell.lbl_TotalShowOff4Post.text = newlikes;
                        [cell.btn_ShowOff setImage:[UIImage imageNamed:@"bragger_Profile_Showoff_blue_button.png"] forState:UIControlStateNormal];

                    }

                }
            }
        }
    }
}

#pragma mark - rebrag

// ReBrag the Post
-(void)act_Rebrag:(UIButton *) sender
{
    
    NSString *urlAsString = GETAPILINK(@"postwebs/RePost/");
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];
    
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&post_id=%@",[postIdArr objectAtIndex:sender.tag]]];
    
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
                NSDictionary *deserializedDictionary = jsonObject;
                if ([[deserializedDictionary objectForKey:@"jsonstatus" ] isEqualToString:@"fail"])
                {
                    UIAlertView *alert_Follower = [[UIAlertView alloc] initWithTitle:@"Bragger" message:[deserializedDictionary valueForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert_Follower show];
                }
                else
                {
                    //cell.lbl_TotalReBrags4Post.text = [NSString stringWithFormat:@"%@ Rebrags",(NSString *)[totalRebrag4Post objectAtIndex:indexPath.row]];
                    UIButton *btn = (UIButton *)sender;
                    int postId = btn.tag;
                    
                    NSString* oldlikes = [totalRebrag4Post objectAtIndex:postId];
                    int n = oldlikes.intValue;
                    NSString* newlikes = [NSString stringWithFormat:@"%d Rebrags", n+1];
                    
                    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:postId inSection:0];
                    MABraggingStreamCustomCell *cell = (MABraggingStreamCustomCell *)[tbl_Braggers cellForRowAtIndexPath:rowToReload];
                    cell.lbl_TotalReBrags4Post.text = newlikes;
                    [cell.btn_Rebrag setImage:[UIImage imageNamed:@"bragger_Profile_Rebrags_blue_button.png"] forState:UIControlStateNormal];
                    
                    //[self act_ChangeSegment:nil];
                }
            }
        }
    }
    
}

- (void)GotoCommentsView:(UIButton *)sender
{
    MACommentsViewController *obj_CommentsVC;
    
    obj_CommentsVC = [[MACommentsViewController alloc] initWithNibName:@"MACommentsViewController" bundle:nil];
    obj_CommentsVC.str_RealName = (NSString*)[nickNameArr objectAtIndex:sender.tag];
    obj_CommentsVC.str_Location = (NSString*)[locationArr objectAtIndex:sender.tag];
    obj_CommentsVC.str_UserImagePath = [NSString stringWithFormat:@"%@",[userImageArr objectAtIndex:sender.tag]];
    obj_CommentsVC.str_TotalRebrag = [NSString stringWithFormat:@"%@",[totalRebrag4Post objectAtIndex:sender.tag]];
    obj_CommentsVC.str_TotalPost4Like = (NSString*)[totalLike4Post objectAtIndex:sender.tag];
    obj_CommentsVC.str_TotalShowOff = (NSString *)[totalDisLike4Post objectAtIndex:sender.tag];
    obj_CommentsVC.postId = (NSString *)[postIdArr objectAtIndex:sender.tag];
    obj_CommentsVC.str_PostTitle = (NSString *)[postTitleArr objectAtIndex:sender.tag];
    obj_CommentsVC.str_HashTag = (NSString *)[isHashTagArr objectAtIndex:sender.tag];
    obj_CommentsVC.str_postedImageUrl = [NSString stringWithFormat:@"%@",[postMediaFileArr objectAtIndex:sender.tag]];
    obj_CommentsVC.PostOwnerUserId = [NSString stringWithFormat:@"%@",[memberUserIdArr objectAtIndex:sender.tag]];
    
    obj_CommentsVC.str_Like = [NSString stringWithFormat:@"%@",[isLikePostArr objectAtIndex:sender.tag]];
    obj_CommentsVC.str_Rebrag = [NSString stringWithFormat:@"%@",[isRebragArr objectAtIndex:sender.tag]];
    obj_CommentsVC.str_ShowOff = [NSString stringWithFormat:@"%@",[isDislikePostArr objectAtIndex:sender.tag]];
    if ([(NSString *)[isFollowingFlagArr objectAtIndex:sender.tag] isEqualToString:@"not following"])
        obj_CommentsVC.isFollowing = NO;
    else
        obj_CommentsVC.isFollowing = YES;
    
    //        obj_CommentsVC.myProperty = NO;
    g_isCommentedRow = sender.tag;
    [self presentViewController:obj_CommentsVC animated:YES completion:nil];
}

#pragma mark - comment a post
// Go to Comment view Controller
- (void)act_Comment:(UIButton *)sender
{
    
    if ([MABraggerLoginViewController isBragAnnIsSelected])
    {
        [self showSignInAlert];
    }
    else
    {
        HUD = [[MBProgressHUD alloc] initWithView:self.view];
        [self.view addSubview:HUD];
        [self.view bringSubviewToFront:HUD];
        HUD.dimBackground = YES;
        // Regiser for HUD callbacks so we can remove it from the window at the right time
        HUD.delegate = self;
        // Show the HUD while the provided method executes in a new thread
        [HUD showWhileExecuting:@selector(GotoCommentsView:) onTarget:self withObject:sender animated:YES];
    }
}

#pragma mark - post comment
// Post the Comments to server
-(void)postCommentToServer:(NSString *)comment_txt postId:(NSInteger *)postId
{
    if ([comment_txt isEqual:[NSNull null]] || [comment_txt isEqual:@""])
    {
        UIAlertView *alert_CommentPost = [[UIAlertView alloc] initWithTitle:@"Bragger" message:@"Please enter comments" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
        [alert_CommentPost show];
    }
    else
    {
        NSString *urlAsString = GETAPILINK(@"postwebs/CommentOnPost/");
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&post_id=%@",[postIdArr objectAtIndex:postId]]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&comment_text=%@",comment_txt]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&mediatype=photo"]];
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
                
                if ([[jsonObject objectForKey:@"jsonstatus" ] isEqualToString:@"fail"])
                {
                    UIAlertView *alert_CommentPost = [[UIAlertView alloc] initWithTitle:@"Bragger" message:[jsonObject valueForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert_CommentPost show];
                }
                int tempPost = (int)postId;
                isCommentIsPosted[tempPost] = YES;
                int value = [[totalCommentArr objectAtIndex:tempPost] intValue];
                value++;
                countTotalComments = [NSString stringWithFormat:@"%d",value];
                [self act_ChangeSegment:nil];
            }
            else if (error != nil)
            {
                NSLog(@"An error happened while deserializing the JSON data.");
            }
        }
        else if ([data length] == 0 && error == nil){
            NSLog(@"Nothing was downloaded.");
        }
        else if (error != nil){
            NSLog(@"Error happened = %@", error);
        }
    }
    
}

#pragma mark - bragger profile
// Go to Braggers Profile Screen
- (void)act_BraggerProfile:(UIButton*)sender
{
    if ([MABraggerLoginViewController isBragAnnIsSelected])
    {
        [self showSignInAlert];
    }
    else
    {
       
        MABraggerProfileViewController *obj_BraggerProfile;
        obj_BraggerProfile = [[MABraggerProfileViewController alloc] initWithNibName:@"MABraggerProfileViewController" bundle:nil];
		 obj_BraggerProfile.str_SelectedUserId = (NSString*)[memberUserIdArr objectAtIndex:sender.tag];
        [self presentViewController:obj_BraggerProfile animated:YES completion:nil];
    }
}


#pragma mark - discover post annonymous

// Show the Brags to Anonymous User
-(void)DiscoverPostAnonymous:(NSString *)filterType postLocation:(NSString *)postLocation
{//no-call
    
    
	NSLog(@"%@",filterType);
    /*
    NSString *urlAsString;
    
    [self resetScrollView];
    
    
    if([filterType isEqualToString:@"top"])
        urlAsString = GETAPILINK(@"postwebs/TopPosts/");
    else
        urlAsString = GETAPILINK(@"postwebs/DiscoverPosts/");
    
    if ([filterType isEqualToString:@"latest"])
    {
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?post_filter=latest"]];
    }
    else if([filterType isEqualToString:@"top"])
    {
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?post_filter=top"]];
        
    }
    else if ([filterType isEqualToString:@"nearby"])
    {
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?post_filter=nearby&post_location=%@",postLocation]];
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
            NSMutableArray* tempArray;
            
            tempArray = (NSMutableArray *)[jsonObject valueForKey:@"fullname"];
            fullNameArr = tempArray.copy;
            userImageArr =  (NSMutableArray *)[jsonObject valueForKey:@"user_image"];
            locationArr =  (NSMutableArray *)[jsonObject valueForKey:@"post_location"];
            memberUserIdArr = (NSMutableArray *)[jsonObject valueForKey:@"post_owner_user_id"];
            tempArray = (NSMutableArray *)[jsonObject valueForKey:@"total_like"];
            totalLike4Post = tempArray.copy;
            totalDisLike4Post =  (NSMutableArray *)[jsonObject valueForKey:@"total_dislike"];
            postMediaFileArr = (NSMutableArray *)[jsonObject valueForKey:@"post_mediafile"];
            postMediaTypeArr = (NSMutableArray *)[jsonObject valueForKey:@"mediatype"];
            postIdArr =  (NSMutableArray *)[jsonObject valueForKey:@"post_id"];
            postTitleArr = (NSMutableArray *)[jsonObject  valueForKey:@"post_title"];
            totalCommentArr = (NSMutableArray *)[jsonObject  valueForKey:@"total_comment"];
            postTimeArr = (NSMutableArray *)[jsonObject  valueForKey:@"post_date"];
            isHashTagArr = (NSMutableArray *)[jsonObject valueForKey:@"hash_tag"];
			
        }
        else if (error != nil)
        {
            NSLog(@"An error happened while deserializing the JSON data.");
        }
        
        
    }
    else if ([data length] == 0 && error == nil){
        NSLog(@"Nothing was downloaded.");
    }
    else if (error != nil){
        NSLog(@"Error happened = %@", error);
    }
    */
}

// SignIn AlertView
-(void)showSignInAlert
{
    UIAlertView *alertsuccess = [[UIAlertView alloc] initWithTitle:@"Brag" message:@"Please Login"
                                                          delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alertsuccess show];
    
}

#pragma mark - media player

// Play the Voice through Audio Player
- (void)act_GoToAudioPlayer:(UIButton*)sender
{
    NSString* resourcePath = [NSString stringWithFormat:@"%@",[postMediaFileArr objectAtIndex:sender.tag]]; //your url
    NSData *_objectData = [NSData dataWithContentsOfURL:[NSURL URLWithString:resourcePath]];
    NSError *error;
    
    player = [[AVAudioPlayer alloc] initWithData:_objectData error:&error];
    player.numberOfLoops = 0;
    player.volume = 1.0f;
    [player prepareToPlay];
    
    if (player == nil)
        NSLog(@"%@", [error description]);
    else
        [player play];
    
}

// Play the Video through Video Player
- (void)act_GoToVideoPlayer:(UIButton*)sender
{
    isVideoImage = YES;
    NSString* resourcePath = [NSString stringWithFormat:@"%@",[postMediaFileArr objectAtIndex:sender.tag]];
    
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:resourcePath] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
    
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
    if (conn)
    {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        _responseData = [[NSMutableData alloc] init];
    }
    else
    {
        // Inform the user that the connection failed.
    }
    
}

// Display the Image in Full Screen
- (void)act_GoToImageViewer:(UIButton*)sender
{
	tbl_Braggers.userInteractionEnabled = NO;
    [self.view bringSubviewToFront:img_FullScreen];
    [self.view bringSubviewToFront:btn_ExitFullScreen];
    
    img_FullScreen.hidden = NO;
    img_FullScreen.contentMode = UIViewContentModeScaleAspectFit;
    btn_ExitFullScreen.hidden = NO;
    NSString *str_PostImageURL = [NSString stringWithFormat:@"%@",[postMediaFileArr objectAtIndex:sender.tag]];
    NSURL *url_PostImage = [NSURL URLWithString:str_PostImageURL];
    dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
    dispatch_async(q, ^{
        /* Fetch the image from the server... */
        NSData *data_PostImage = [NSData dataWithContentsOfURL:url_PostImage];
        UIImage *img_PostImage = [[UIImage alloc] initWithData:data_PostImage];
        dispatch_async(dispatch_get_main_queue(), ^{
            img_FullScreen.image = img_PostImage;
        });
    });
    
}


// Get the Thumbnail of Video
- (void)thumbnailOfVideo:(NSURL *)videoURL
{
//    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
//    AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
//    generateImg.appliesPreferredTrackTransform = YES;
//    NSError *error = NULL;
//    CMTime time = [asset duration];
//    time.value = 0;
//    CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&error];
//    NSLog(@"error==%@, Refimage==%@", error, refImg);
//    
//    FrameImage = [[UIImage alloc] initWithCGImage:refImg];
    
//    isVideoImage = NO;
//    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:videoURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:30];
//    
//    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
//    if (conn)
//    {
//        // Create the NSMutableData to hold the received data.
//        // receivedData is an instance variable declared elsewhere.
//        _responseData = [[NSMutableData alloc] init];
//    }
//    else
//    {
//        // Inform the user that the connection failed.
//    }

    
}


- (IBAction)act_ExitFromFullScreen:(id)sender
{
	tbl_Braggers.userInteractionEnabled = YES;
    img_FullScreen.image = nil;
    img_FullScreen.hidden = YES;
    btn_ExitFullScreen.hidden = YES;
}


#pragma mark -----------------------
#pragma mark - NSURLConnection Delegate To Play Videos

//Download the Video Data from Server
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
    
    
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse
{
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  
    if (isVideoImage)
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        path = [documentsDirectory stringByAppendingPathComponent:@"myMove.mov"];
        
        NSLog(@"path:%@",path);
        [[NSFileManager defaultManager] createFileAtPath:path contents:_responseData attributes:nil];
        
        
        NSURL *moveUrl = [NSURL fileURLWithPath:path];
        movieController =  [[MPMoviePlayerController alloc] initWithContentURL:moveUrl];
        movieController.controlStyle = MPMovieControlStyleEmbedded;
        movieController.shouldAutoplay = YES;
        movieController.scalingMode=MPMovieScalingModeFill;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(moviePlayBackDidFinish:)
                                                     name:MPMoviePlayerPlaybackDidFinishNotification
                                                   object:self.movieController];
        
        [self.view addSubview:movieController.view];
        [movieController prepareToPlay];
        [movieController setFullscreen:YES animated:YES];

    }
    else
    {
//        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:moveUrl options:nil];
//        AVAssetImageGenerator *generateImg = [[AVAssetImageGenerator alloc] initWithAsset:asset];
//        generateImg.appliesPreferredTrackTransform = YES;
//        NSError *error = NULL;
//        CMTime time = CMTimeMake(1, 2);
//        CGImageRef refImg = [generateImg copyCGImageAtTime:time actualTime:NULL error:&error];
//        NSLog(@"error==%@, Refimage==%@", error, refImg);
//        
//        FrameImage= [[UIImage alloc] initWithCGImage:refImg];
        
        
        
    }
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    
    NSLog(@"error:%@",[error localizedDescription]);
    
}

#pragma mark -----------------------
#pragma mark - MPMoviePlayer Notification Methods
// Video Play Back Did Finish
- (void)moviePlayBackDidFinish:(NSNotification *)notification {
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    NSError *err;
    [self.movieController stop];
    [self.movieController.view removeFromSuperview];
    self.movieController = nil;
    NSLog(@"path:%@",path);
    [[NSFileManager defaultManager] removeItemAtPath:path error:&err]; //createFileAtPath:path contents:_responseData attributes:nil];
    NSLog(@"error:%@",[err localizedDescription]);
}

#pragma mark -----------------------
#pragma mark - Location Finder
// Get the Current User Location
-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    
    [manager stopUpdatingLocation];
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

// Refresh the Braggers Posts
- (void)refresh:(UIRefreshControl *)refreshControl
{
    [self act_ChangeSegment:nil];
    [refreshControl endRefreshing];
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

#pragma mark - flag
- (void)act_Flag:(UIButton*)sender
{
	
	UIAlertView *alert = [[UIAlertView alloc]
						  initWithTitle:@"What's wrong with this brag?"
						  message:nil
						  delegate:self
						  cancelButtonTitle:@"Cancel"
						  otherButtonTitles:@"Spam", @"Inappropriate",@"Bullying",@"Block Author", nil];
	alert.transform=CGAffineTransformMakeScale(1.0, 0.75);
	alert.alertViewStyle=UIAlertViewStylePlainTextInput;
	UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDefault;
    alertTextField.placeholder = @"Feedback";
    alert.tag = sender.tag;
    [alert show];
	
	
	
}


- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
	NSLog(@"tag:%ld",(long)alertView.tag);
    // the user clicked OK
    if (buttonIndex == 0)
	{
        // do something here...
    }
	else if (buttonIndex == 1)
	{
//		NSLog(@"alert:%@",[[alertView textFieldAtIndex:0]text]);
		[self FlagPost:[[alertView textFieldAtIndex:0]text] postId:[postIdArr objectAtIndex:alertView.tag] feedBackType:@"1"];
	}
	else if (buttonIndex == 2)
	{
		[self FlagPost:[[alertView textFieldAtIndex:0]text] postId:[postIdArr objectAtIndex:alertView.tag] feedBackType:@"2"];
	}
	else if (buttonIndex == 3)
	{
		[self FlagPost:[[alertView textFieldAtIndex:0]text] postId:[postIdArr objectAtIndex:alertView.tag] feedBackType:@"3"];
	}
	else if (buttonIndex == 4)
	{
		[self FlagPost:[[alertView textFieldAtIndex:0]text] postId:[postIdArr objectAtIndex:alertView.tag] feedBackType:@"4"];
	}


}


-(void)FlagPost:(NSString *)feedBack postId:(NSString *)postId feedBackType:(NSString *)feedBackType
{


	NSString *urlAsString = GETAPILINK(@"Postnewwebservices/AddFeedback/");
	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];
	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];

	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&post_id=%@",postId]];
	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&feedback_type=%@",feedBackType]];
	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&feedback=%@",feedBack]];
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

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView1 willDecelerate:(BOOL)decelerate;
{
    [self scrollViewDidEndDecelerating:scrollView1];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView1
{
    //UIView* v1 = UIView a
    CGPoint test = scrollView1.contentOffset;
    int totlaheight = scrollView1.contentSize.height;
    int screenheight = self.view.frame.size.height+100;
    if (test.y > totlaheight-screenheight)
    {
        displayedCount += 5;
        if (displayedCount > [fullNameArr count])
            displayedCount = [fullNameArr count];
        
        int totaltableheight = 423*displayedCount+50;
        tbl_Braggers.frame = CGRectMake(0, 4, 299, totaltableheight);
        
        //for (int i = displayedCount - 5; i < displayedCount; i ++)
        {
            NSIndexPath* rowToReload1 = [NSIndexPath indexPathForRow:displayedCount - 5 inSection:0];
            NSIndexPath* rowToReload2 = [NSIndexPath indexPathForRow:displayedCount - 4 inSection:0];
            NSIndexPath* rowToReload3 = [NSIndexPath indexPathForRow:displayedCount - 3 inSection:0];
            NSIndexPath* rowToReload4 = [NSIndexPath indexPathForRow:displayedCount - 2 inSection:0];
            NSIndexPath* rowToReload5 = [NSIndexPath indexPathForRow:displayedCount - 1 inSection:0];
            NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload1,rowToReload2, rowToReload3, rowToReload4,rowToReload5,nil];
            [tbl_Braggers reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
        }
        //[tbl_Braggers reloadData];
        
        [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, totaltableheight)];
        
    }
}

- (void) resetScrollView
{
    displayedCount = 5;
    int totaltableheight = 423*displayedCount+50;
    tbl_Braggers.frame = CGRectMake(0, 4, 299, totaltableheight);
    [scrollView setContentSize:CGSizeMake(scrollView.frame.size.width, totaltableheight)];
    [self.scrollView setContentOffset:CGPointZero animated:YES];

}
@end
