//
//  MABraggerProfileViewController.m
//  Bragger
//
//  Created by GaoShen on 2/3/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0f)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)

#import "UIViewController+MJPopupViewController.h"
#import "MABraggerProfileViewController.h"
#import "MABraggerLoginViewController.h"
#import "MACommentsViewController.h"
#import "MABraggingStreamViewController.h"
#import "MADiscoverBraggerViewController.h"
#import "MAShareBragViewController.h"
#import "MASingleton.h"
#import "Constant.h"

BOOL isbtn_PostLikeSelected[0];
BOOL isbtn_ShowOffSelected[0];
BOOL isbtn_RebragSelected[0];
BOOL isbtn_commentIsSeleceted[0];
BOOL isCommentIsPosted[0];
@interface MABraggerProfileViewController ()
{
    NSString *userId;
    NSString *sessionId;
    NSString *str_UserImage;
    NSString *str_MemberId;
    NSMutableArray *arr_PostMediaFile;
	NSMutableArray *arr_PostMediaType;
    NSMutableArray *arr_TotalLike;
    NSMutableArray *arr_TotalDisLike;
    NSMutableArray *arr_TotalRebrag;
    NSMutableArray *arr_PostId;
    NSMutableArray *isLikePostArr;
    NSMutableArray *isDislikePostArr;
    
    NSMutableArray *postTileArr;
    NSMutableArray *totalNoOfComments;
    NSMutableArray *isFollowingFlagArr;
    NSMutableArray *postTimeArr;
	NSMutableArray *hashTagArr;
    NSString *countRebragPost;
    NSString *countTotalCount;
    NSString *countTotalComments;
    NSString *str_followingFlag;
	AVAudioPlayer *player;
	NSMutableData *_responseData;
	NSString *path;
	Reachability *reachability;
	UIAlertView *alert4Connectivity;
	BOOL isAlertShowing;
	NSMutableArray *thumbnailVideoArr;

	
}
@end

@implementation MABraggerProfileViewController
@synthesize txt_CommantbragTxt,str_SelectedUserId,lbl_BraggerName,lbl_BraggerLocation,lbl_TotalFollowers,lbl_TotalFollowing,lbl_TotalBrags,img_BraggerUserImage,btn_AddFollowers;
@synthesize customCell,tbl_BraggerProfilePost,img_PinLocation,isFollowing;
@synthesize movieController;
#pragma mark - init
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
    [super viewWillAppear:animated];
    
	[self checkConnection];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityDidChange:) name:kReachabilityChangedNotification object:nil];
}

-(void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
	[[NSNotificationCenter defaultCenter] removeObserver:self name:kReachabilityChangedNotification object:nil];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	
    txt_CommantbragTxt.delegate = self;
    tbl_BraggerProfilePost.rowHeight = 302;
    userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_id"];
 
    // Do any additional setup after loading the view from its nib.
    img_BraggerUserImage.layer.cornerRadius = 60/2;
    img_BraggerUserImage.layer.masksToBounds = YES;
    
    [self GetUserProfilePostToserver:str_SelectedUserId];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self DiscoverPostToserver:str_SelectedUserId];
	[tbl_BraggerProfilePost reloadData];
}

#pragma mark - user profile
// get user profile api call
-(void)GetUserProfilePostToserver:(NSString *)SelectedUserID
{
    NSString *urlAsString = GETAPILINK(@"memberwebs/GetUserProfileByUserId/");
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&other_user_id=%@",SelectedUserID]];
    NSURL *url = [NSURL URLWithString:urlAsString];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"POST"];
	NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    if ([data length] >0 && error == nil)
    {
        error = nil;
        id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		if (jsonObject != nil && error == nil)
        {
            lbl_BraggerName.text = (NSString*)[jsonObject valueForKey:@"nickname"];
            //[cell.btn_Follower setImage:[UIImage imageNamed:@"bragger_Profile_Unfollow_Button"] forState:UIControlStateNormal];

            str_followingFlag = (NSString*)[jsonObject valueForKey:@"following"];
            if ([str_followingFlag isEqualToString:@"yes"])
            {
                [btn_AddFollowers setImage: [UIImage imageNamed:@"bragger_Profile_Unfollow_Button.png"] forState:UIControlStateNormal];
                
            }
            else
            {
                [btn_AddFollowers setImage: [UIImage imageNamed:@"bragger_Profile_Follow_Button.png"] forState:UIControlStateNormal];
            
            }
            NSString *userLocation = (NSString*)[jsonObject valueForKey:@"user_location"];
			if ([userLocation isEqual:[NSNull null]] || [userLocation isEqual:@"(null)"])
			{
				lbl_BraggerLocation.text = @"";
				img_PinLocation.hidden = YES;
			}
			else
				lbl_BraggerLocation.text = userLocation;
            str_MemberId = (NSString*)[jsonObject valueForKey:@"id"];
            lbl_TotalFollowing.text = [NSString stringWithFormat:@"%@ Following",[jsonObject valueForKey:@"total_following"]];
            lbl_TotalFollowers.text = [NSString stringWithFormat:@"%@ Followers",[jsonObject valueForKey:@"total_followers"]];
            if ([[jsonObject valueForKey:@"user_image"] isEqual:[NSNull null]])
            {
                img_BraggerUserImage.image = [UIImage imageNamed:@"default_profileUserImage.png"];
            }
            else if ([[jsonObject valueForKey:@"user_image"] isEqualToString:@"invalid file"])
            {
                img_BraggerUserImage.image = [UIImage imageNamed:@"default_profileUserImage.png"];
            }
            else
            {
				str_UserImage = [NSString stringWithFormat:@"%@",[jsonObject valueForKey:@"user_image"]];
				NSURL *url_Image = [NSURL URLWithString:str_UserImage];
				NSData *data_Image = [NSData dataWithContentsOfURL:url_Image];
				UIImage *img_UserName = [[UIImage alloc] initWithData:data_Image];
				img_BraggerUserImage.image = img_UserName;
            }
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
    else if (error != nil)
	{
        NSLog(@"Error happened = %@", error);
    }
}

#pragma mark - discover post by id
// get user post api call
-(void)DiscoverPostToserver:(NSString *)SelectedUserID
{
    NSString *urlAsString = GETAPILINK(@"postwebs/GetUserPostsByUserId/");
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&other_user_id=%@",SelectedUserID]];
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
			NSLog(@"JsonObject:%@",jsonObject);
            arr_PostMediaFile = (NSMutableArray*)[[jsonObject valueForKey:@"Post"] valueForKey:@"post_mediafile"];
			arr_PostMediaType = (NSMutableArray*)[[jsonObject valueForKey:@"Post"] valueForKey:@"mediatype"];
            arr_TotalLike = (NSMutableArray*)[[jsonObject valueForKey:@"Post"] valueForKey:@"total_like"];
            arr_TotalDisLike = (NSMutableArray*)[[jsonObject valueForKey:@"Post"] valueForKey:@"total_dislike"];
            arr_TotalRebrag = (NSMutableArray*)[[jsonObject valueForKey:@"Post"] valueForKey:@"total_shared"];
            //isLikePostArr = (NSMutableArray *)[jsonObject valueForKey:@"like_flag"];
            //isDislikePostArr = (NSMutableArray *)[jsonObject valueForKey:@"dislike_flag"];
            //isRebragArr = (NSMutableArray *)[jsonObject valueForKey:@"shared_flag"];
            
            isbtn_PostLikeSelected[[arr_TotalLike count]] = NO;
            arr_PostId = (NSMutableArray*)[[jsonObject valueForKey:@"Post"] valueForKey:@"id"];
            postTileArr = (NSMutableArray *)[[jsonObject valueForKey:@"Post"] valueForKey:@"post_title"];
            postTimeArr = (NSMutableArray *)[[jsonObject valueForKey:@"Post"] valueForKey:@"post_date"];
            totalNoOfComments = (NSMutableArray*)[[jsonObject valueForKey:@"Post"] valueForKey:@"total_comment"];
            hashTagArr = (NSMutableArray*)[[jsonObject valueForKey:@"Post"] valueForKey:@"hash_tag"];
            lbl_TotalBrags.text = [NSString stringWithFormat:@"%lu Brags",(unsigned long)[jsonObject count]];
			thumbnailVideoArr = (NSMutableArray *)[[jsonObject valueForKey:@"Post"] valueForKey:@"media_type_file"];
			NSLog(@"thum:%@",thumbnailVideoArr);
			
        }
        else if (error != nil)
        {
            NSLog(@"An error happened while deserializing the JSON data.");
        }
    }
	
}

#pragma mark - Table View

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [arr_PostMediaFile count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MABraggerProfileCustomCell *cell = (MABraggerProfileCustomCell*) [tableView dequeueReusableCellWithIdentifier:[MABraggerProfileCustomCell reuseIdentifier]];
    
    if(cell == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:@"MABraggerProfileCustomCell" owner:self options:nil];
        cell = customCell;
        customCell = nil;
    }
	// set title
    cell.titleLabel.text = (NSString *)[postTileArr objectAtIndex:indexPath.row];

	
	 if ([[arr_PostMediaType objectAtIndex:indexPath.row] isEqual:[NSNull null]])
	 {
	 UILabel  * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 299, 198)];
	 label.backgroundColor = [UIColor clearColor];
	 label.textColor=[UIColor blackColor];
	 label.numberOfLines=0;
	 if (![[arr_PostMediaFile objectAtIndex:indexPath.row] isEqual:[NSNull null]])
	 {
	 label.text = (NSString *)[arr_PostMediaFile objectAtIndex:indexPath.row];
	 }
	 
	 [label sizeToFit];
	 [cell addSubview:label];
	  cell.titleLabel.text = @"";
		 cell.btnLIkeVw.backgroundColor = [UIColor lightGrayColor];
		 cell.btnShowOffVw.backgroundColor = [UIColor lightGrayColor];
		 cell.btnRebragVw.backgroundColor = [UIColor lightGrayColor];
	 }
	 else
	 {
	 
	 if ([(NSString *)[arr_PostMediaType objectAtIndex:indexPath.row] isEqualToString:@"audio"])
	 {
	 cell.img_FromPostMediaFile.image = [UIImage imageNamed:@"posted_Audio.png"];
	 cell.mediaBtn.userInteractionEnabled = YES;
	 [cell.mediaBtn addTarget:self action:@selector(act_GoToAudioPlayer:) forControlEvents:UIControlEventTouchUpInside];
	 cell.titleLabel.text = (NSString *)[postTileArr objectAtIndex:indexPath.row];
	 
	 }
	 else if ([(NSString *)[arr_PostMediaType objectAtIndex:indexPath.row] isEqualToString:@"video"])
	 {
//	 cell.img_FromPostMediaFile.image = [UIImage imageNamed:@"posted_Video.png"];

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
		 
		 UILabel *tapToPlayVid =  [[UILabel alloc]initWithFrame:CGRectMake(75, 75, 200, 30)];
		 tapToPlayVid.text = @"Tap to Play video";
		 tapToPlayVid.font = [UIFont systemFontOfSize:18.0];
		 tapToPlayVid.textColor = [UIColor blackColor];
		 [cell addSubview:tapToPlayVid];

	 cell.mediaBtn.userInteractionEnabled = YES;
	 [cell.mediaBtn addTarget:self action:@selector(act_GoToVideoPlayer:) forControlEvents:UIControlEventTouchUpInside];
	 cell.titleLabel.text = (NSString *)[postTileArr objectAtIndex:indexPath.row];
	 }
		 
	 else if([(NSString *)[arr_PostMediaType objectAtIndex:indexPath.row] isEqualToString:@"photo"])
	 {
	 cell.mediaBtn.userInteractionEnabled = NO;
	 cell.titleLabel.text = (NSString *)[postTileArr objectAtIndex:indexPath.row];
	 NSString *str_PostImageURL = [NSString stringWithFormat:@"%@",[arr_PostMediaFile objectAtIndex:indexPath.row]];
	 NSURL *url_PostImage = [NSURL URLWithString:str_PostImageURL];
	 
	 dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
	 dispatch_async(q, ^{
	NSData *data_PostImage = [NSData dataWithContentsOfURL:url_PostImage];
	UIImage *img_PostImage = [[UIImage alloc] initWithData:data_PostImage];
	dispatch_async(dispatch_get_main_queue(), ^{
		cell.img_FromPostMediaFile.image = img_PostImage;
	});
});

}
else
{
	UILabel  * label = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 299, 198)];
	label.backgroundColor = [UIColor clearColor];
	label.textColor=[UIColor blackColor];
	label.numberOfLines=0;
	label.text = (NSString *)[postTileArr objectAtIndex:indexPath.row];
	[label sizeToFit];
	[cell addSubview:label];
	cell.titleLabel.text = @"";
	cell.btnLIkeVw.backgroundColor = [UIColor lightGrayColor];
	cell.btnShowOffVw.backgroundColor = [UIColor lightGrayColor];
	cell.btnRebragVw.backgroundColor = [UIColor lightGrayColor];
	
}

}


	 
//    // Bragger Media Post
//    if ([[arr_PostMediaFile objectAtIndex:indexPath.row] isEqual:[NSNull null]])
//    {
//        cell.img_FromPostMediaFile.image = [UIImage imageNamed:@"beautiful-sea-view-wallpaper.jpg"];
//    }
//    else if ([[arr_PostMediaFile objectAtIndex:indexPath.row] isEqualToString:@"invalid file"])
//    {
//        cell.img_FromPostMediaFile.image = [UIImage imageNamed:@"beautiful-sea-view-wallpaper.jpg"];
//    }
//    else
//    {
//		NSLog(@"%@",[arr_PostMediaFile objectAtIndex:indexPath.row]);
//        NSString *str_PostImageURL = [NSString stringWithFormat:@"%@",[arr_PostMediaFile objectAtIndex:indexPath.row]];
//        NSURL *url_PostImage = [NSURL URLWithString:str_PostImageURL];
//        
//        dispatch_queue_t q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
//        dispatch_async(q, ^{
//            /* Fetch the image from the server... */
//            NSData *data_PostImage = [NSData dataWithContentsOfURL:url_PostImage];
//            UIImage *img_PostImage = [[UIImage alloc] initWithData:data_PostImage];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                /* This is the main thread again, where we set the tableView's image to
//                 be what we just fetched. */
//                cell.img_FromPostMediaFile.image = img_PostImage;
//            });
//        });
//        
//    }
    // Check Like
    cell.btn_PostLike.tag = indexPath.row;
    if ([[arr_TotalLike objectAtIndex:indexPath.row] isEqual:[NSNull null]])
		cell.totalLike4PostLbl.text = @"0";
    else
    {
        cell.totalLike4PostLbl.text = (NSString *)[arr_TotalLike objectAtIndex:indexPath.row];
        if (isbtn_PostLikeSelected[indexPath.row] == YES || [(NSString *)[arr_TotalLike objectAtIndex:indexPath.row] isEqualToString:@"1"])
        {
			cell.totalLike4PostLbl.text = [NSString stringWithFormat:@"%@",(NSString *)[arr_TotalLike objectAtIndex:indexPath.row]];
			[cell.btn_PostLike setImage:[UIImage imageNamed:@"bragger_Profile_Like_button_blue.png"] forState:UIControlStateNormal];
        }
    }
    cell.btn_ShowOff.tag = indexPath.row;
	// showOff
	if ([[arr_TotalDisLike objectAtIndex:indexPath.row] isEqual:[NSNull null]] || [[arr_TotalDisLike objectAtIndex:indexPath.row] isEqualToString:@"(null)"])
		cell.totalShowOff4PostLbl.text = @"0";
	else
	{
		if (isbtn_ShowOffSelected[indexPath.row] == YES || [(NSString *)[arr_TotalDisLike objectAtIndex:indexPath.row] isEqualToString:@"1"])
		{
			cell.totalShowOff4PostLbl.text = [NSString stringWithFormat:@"%@",(NSString *)[arr_TotalDisLike objectAtIndex:indexPath.row]];
			[cell.btn_ShowOff setImage:[UIImage imageNamed:@"bragger_Profile_Showoff_blue_button.png"] forState:UIControlStateNormal];
		}
		else
			cell.totalShowOff4PostLbl.text = (NSString *)[arr_TotalDisLike objectAtIndex:indexPath.row];
	}
	// rebrag
	cell.btnReBrag.tag = indexPath.row;
	if ([[arr_TotalRebrag objectAtIndex:indexPath.row] isEqual:[NSNull null]] || [[arr_TotalRebrag objectAtIndex:indexPath.row] isEqualToString:@"(null)"])
		cell.totalReBrags4PostLbl.text = @"0";
	else
	{
		if (isbtn_RebragSelected[indexPath.row] == YES || [(NSString *)[arr_TotalRebrag objectAtIndex:indexPath.row] isEqualToString:@"1"])
		{
			cell.totalReBrags4PostLbl.text = [NSString stringWithFormat:@"%@",(NSString *)[arr_TotalRebrag objectAtIndex:indexPath.row]];//[NSString stringWithFormat:@"%@",countRebragPost];
			[cell.btnReBrag setImage:[UIImage imageNamed:@"bragger_Profile_Rebrags_blue_button.png"] forState:UIControlStateNormal];
		}
		else
			cell.totalReBrags4PostLbl.text = (NSString *)[arr_TotalRebrag objectAtIndex:indexPath.row];
	}
	
	
	if ([str_SelectedUserId isEqualToString:userId])
	{
		cell.btnReBrag.userInteractionEnabled = NO;
		cell.btnRebragVw.userInteractionEnabled = NO;
	}
	
    //check Comment
    cell.btn_Comment.tag = indexPath.row;
    cell.btnLIkeVw.tag = indexPath.row;
    cell.btnShowOffVw.tag = indexPath.row;
    cell.btnRebragVw.tag = indexPath.row;
    [cell.btn_PostLike addTarget:self action:@selector(act_LikePost:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn_ShowOff addTarget:self action:@selector(act_DisLikePost:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn_Comment addTarget:self action:@selector(act_CommentsBtn:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnReBrag addTarget:self action:@selector(act_Rebragbtn:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnLIkeVw addTarget:self action:@selector(act_LikePost:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnShowOffVw addTarget:self action:@selector(act_DisLikePost:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btnRebragVw addTarget:self action:@selector(act_Rebragbtn:) forControlEvents:UIControlEventTouchUpInside];
       // set post time
	if ([[postTimeArr objectAtIndex:indexPath.row] isEqual:[NSNull null]])
	{
			cell.timeLbl.text =@"";
	}
	else
	{
		
	
		cell.timeLbl.text = [MASingleton  getCommentTime:(NSString *)[postTimeArr objectAtIndex:indexPath.row]];
	}
    
	// set total comments
	NSLog(@"xxx%@",[totalNoOfComments objectAtIndex:indexPath.row]);
	if ([[totalNoOfComments objectAtIndex:indexPath.row] isEqual:[NSNull null]] || [[totalNoOfComments objectAtIndex:indexPath.row] isEqualToString:@"(null)"])
		[cell.btn_Comment setTitle:@"0 Comments" forState:UIControlStateNormal];
	else
	{
//		if (isbtn_commentIsSeleceted[indexPath.row] == YES)
//			[cell.btn_Comment setTitle:[NSString stringWithFormat:@"%@ comments",totalNoOfComments] forState:UIControlStateNormal];
//		else
			[cell.btn_Comment setTitle:[NSString stringWithFormat:@"%@ comments",(NSString *)[totalNoOfComments objectAtIndex:indexPath.row]] forState:UIControlStateNormal];
	}
	// hash tag
	if ([[hashTagArr objectAtIndex:indexPath.row] isEqual:[NSNull null]] || [[hashTagArr objectAtIndex:indexPath.row] isEqualToString:@"(null)"])
	{
		cell.hashTag.text = @" ";
	}
	else
	{
		cell.hashTag.text = (NSString *)[hashTagArr objectAtIndex:indexPath.row];
	}
	// comments
	cell.txt_CommentBragText.tag = indexPath.row;
	cell.txt_CommentBragText.delegate=self;
	cell.mediaBtn.tag = indexPath.row;
    return cell;
}



#pragma mark - text field and delegates
// hide keyboard
-(IBAction)HdKeyboard:(id)sender
{
    [txt_CommantbragTxt resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) animateTextView:(BOOL) up
{
    const int movementDistance =130.0;
    const float movementDuration = 0.3f;
    int movement= movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextView : YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[self  animateTextView :NO];
	[self postCommentToServer:textField.text postId:textField.tag];
	textField.text = @"";
}

#pragma mark - follow user
// add follower apic all
- (IBAction)act_Followers:(id)sender
{
    
    if ([str_followingFlag isEqualToString:@"no"])
    {
    
    NSString *urlAsString = GETAPILINK(@"memberwebs/AddFollowers/");
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&to_user_id=%@",str_MemberId]];
    NSURL *url = [NSURL URLWithString:urlAsString];
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
                NSDictionary *deserializedDictionary = jsonObject;
                if ([[deserializedDictionary objectForKey:@"jsonstatus" ] isEqualToString:@"ok"])
                {
                    [btn_AddFollowers setImage:[UIImage imageNamed:@"bragger_Profile_Unfollow_Button"] forState:UIControlStateNormal];
					str_followingFlag = @"yes";
                }
                else
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
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&to_user_id=%@",str_MemberId]];
        
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
					if ([[deserializedDictionary objectForKey:@"jsonstatus" ] isEqualToString:@"ok"])
					{

                    [btn_AddFollowers setImage: [UIImage imageNamed:@"bragger_Profile_Follow_Button.png"] forState:UIControlStateNormal];
                    str_followingFlag = @"no";
					}
                    if ([[deserializedDictionary objectForKey:@"jsonstatus" ] isEqualToString:@"fail"])
                    {
                        UIAlertView *alert_Follower = [[UIAlertView alloc] initWithTitle:@"Bragger" message:[deserializedDictionary valueForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                        [alert_Follower show];
                    }
                    
                }
            }
        }
        
    }

   
}

#pragma mark - bragging stream
- (IBAction)act_Bragging:(id)sender
{
    MABraggingStreamViewController *obj_AboutVC;
    obj_AboutVC = [[MABraggingStreamViewController alloc] initWithNibName:@"MABraggingStreamViewController" bundle:nil];
    [self presentViewController:obj_AboutVC animated:YES completion:nil];
}

#pragma mark - share brag
- (IBAction)act_SHareBrag:(id)sender
{
    MAShareBragViewController *obj_AboutVC;
	obj_AboutVC = [[MAShareBragViewController alloc] initWithNibName:@"MAShareBragViewController" bundle:nil];
	[self presentPopupViewController:obj_AboutVC animationType:MJPopupViewAnimationFade];

	obj_AboutVC.view1=2;
}
#pragma mark - discover brag
- (IBAction)act_Braggers:(id)sender
{
    MADiscoverBraggerViewController *obj_AboutVC;
    obj_AboutVC = [[MADiscoverBraggerViewController alloc] initWithNibName:@"MADiscoverBraggerViewController" bundle:nil];
    [self presentViewController:obj_AboutVC animated:YES completion:nil];
}

#pragma mark - comment a post
- (void)act_CommentsBtn:(UIButton*)sender
{
    MACommentsViewController *obj_CommentsVC;
	obj_CommentsVC = [[MACommentsViewController alloc] initWithNibName:@"MACommentsViewController" bundle:nil];
	obj_CommentsVC.str_RealName = lbl_BraggerName.text;
	obj_CommentsVC.str_Location = lbl_BraggerLocation.text;
	obj_CommentsVC.str_UserImagePath = [NSString stringWithFormat:@"%@",str_UserImage];
	if ([[arr_TotalLike objectAtIndex:sender.tag] isEqual:[NSNull null]])
	{
		obj_CommentsVC.str_TotalPost4Like = @"0";
	}
	else
	{
		obj_CommentsVC.str_TotalPost4Like = (NSString*)[arr_TotalLike objectAtIndex:sender.tag];
	}
	obj_CommentsVC.postId = (NSString*)[arr_PostId objectAtIndex:sender.tag];
	obj_CommentsVC.myProperty = YES;
    [self presentViewController:obj_CommentsVC animated:YES completion:nil];
}

#pragma mark - rebrag a post
- (void)act_Rebragbtn:(UIButton*)sender
{
	NSString *urlAsString = GETAPILINK(@"postwebs/RePost/");
	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];
	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];
	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&post_id=%@",[arr_PostId objectAtIndex:sender.tag]]];
	NSURL *url = [NSURL URLWithString:urlAsString];
	NSMutableURLRequest *urlRequest =
	[NSMutableURLRequest requestWithURL:url];
	[urlRequest setTimeoutInterval:30.0f];
	[urlRequest setHTTPMethod:@"POST"];
	NSURLResponse *response = nil;
	NSError *error = nil;
	NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest  returningResponse:&response error:&error];
	if ([data length] >0  && error == nil)
	{
		error = nil;
		id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
		if (jsonObject != nil && error == nil)
		{
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
					UIAlertView *alert_Follower = [[UIAlertView alloc] initWithTitle:@"Bragger" message:[deserializedDictionary valueForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
					[alert_Follower show];
					isbtn_RebragSelected[sender.tag] = YES;
					int value = [[arr_TotalRebrag objectAtIndex:sender.tag] intValue];
					value++;
					countRebragPost = [NSString stringWithFormat:@"%d",value];
                    
                    
                    NSString* old = [arr_TotalRebrag objectAtIndex:sender.tag];
                    NSString* new = [NSString stringWithFormat:@"%d", old.intValue+1];
                    
                    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:sender.tag inSection:0];
                    MABraggerProfileCustomCell *cell = (MABraggerProfileCustomCell *)[tbl_BraggerProfilePost cellForRowAtIndexPath:rowToReload];
                    cell.totalReBrags4PostLbl.text = new;
                    [cell.btnReBrag setImage:[UIImage imageNamed:@"bragger_Profile_Rebrags_blue_button.png"] forState:UIControlStateNormal];

                    //cell.totalReBrags4PostLbl.text = [NSString stringWithFormat:@"%@",countRebragPost];
                    //[cell.btnReBrag setImage:[UIImage imageNamed:@"bragger_Profile_Rebrags_blue_button.png"] forState:UIControlStateNormal];

				}
			}
		}
	}
	//[tbl_BraggerProfilePost reloadData];
	
}

#pragma mark - back
- (IBAction)act_BackButtonProfile:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - like or dislike a post

- (void)act_LikePost:(UIButton *)sender
{
    [self likeOrDislikePostServer:@"yes" Id:sender.tag];
    
}

- (void)act_DisLikePost:(UIButton *)sender
{
    [self likeOrDislikePostServer:@"no" Id:sender.tag];
}

// like or dislike a post api call
-(void)likeOrDislikePostServer:(NSString *)likeOrDisLike Id:(int)nID
{
    NSString* postId = [arr_PostId objectAtIndex:nID];
    NSString *urlAsString = GETAPILINK(@"postwebs/LikeDislikePost/");
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];
	urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&post_id=%@",postId]];
    urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&like_dislike_status=%@",likeOrDisLike]];
	NSURL *url = [NSURL URLWithString:urlAsString];
	NSMutableURLRequest *urlRequest =
	[NSMutableURLRequest requestWithURL:url];
    [urlRequest setTimeoutInterval:30.0f];
    [urlRequest setHTTPMethod:@"POST"];
    NSURLResponse *response = nil;
    NSError *error = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:&response error:&error];
    if ([data length] > 0 && error == nil)
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
                if ([[deserializedDictionary objectForKey:@"jsonstatus" ] isEqualToString:@"fail"])
                {
                    UIAlertView *alert_Follower = [[UIAlertView alloc] initWithTitle:@"Bragger" message:[deserializedDictionary valueForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                    [alert_Follower show];
                }
                else
                {
                    if ([likeOrDisLike isEqualToString:@"yes"])
                    {
                        //[self DiscoverPostToserver:str_SelectedUserId];
                        NSString* oldlikes = [arr_TotalLike objectAtIndex:nID];
                        int n = oldlikes.intValue;
                        NSString* newlikes = [NSString stringWithFormat:@"%d Likes", n+1];
                        
                        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:nID inSection:0];
                        MABraggerProfileCustomCell *cell = (MABraggerProfileCustomCell *)[tbl_BraggerProfilePost cellForRowAtIndexPath:rowToReload];
                        cell.totalLike4PostLbl.text = newlikes;
                        [cell.btn_PostLike setImage:[UIImage imageNamed:@"bragger_Profile_Like_button_blue.png"] forState:UIControlStateNormal];
                    }
                    else{//"no"
                        NSString* oldlikes = [arr_TotalDisLike objectAtIndex:nID];
                        int n = oldlikes.intValue;
                        NSString* newlikes = [NSString stringWithFormat:@"%d", n+1];
                        
                        NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:nID inSection:0];
                        MABraggerProfileCustomCell *cell = (MABraggerProfileCustomCell *)[tbl_BraggerProfilePost cellForRowAtIndexPath:rowToReload];
                        cell.totalShowOff4PostLbl.text = newlikes;
                        [cell.btn_ShowOff setImage:[UIImage imageNamed:@"bragger_Profile_Showoff_blue_button.png"] forState:UIControlStateNormal];
                        
                    }
                }
            }
        }
    }
    //[tbl_BraggerProfilePost reloadData];
}


#pragma mark - post comment
// post comment to server api call
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
		urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&post_id=%@",[arr_PostId objectAtIndex:postId]]];
		urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&comment_text=%@",comment_txt]];
        urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&mediatype=photo"]];
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
				if ([[jsonObject objectForKey:@"jsonstatus" ] isEqualToString:@"fail"])
				{
					UIAlertView *alert_CommentPost = [[UIAlertView alloc] initWithTitle:@"Bragger" message:[jsonObject valueForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
					[alert_CommentPost show];
				}
                int tempPost = (int)postId;
                isCommentIsPosted[tempPost] = YES;
                int value = [[totalNoOfComments objectAtIndex:tempPost] intValue];
                value++;
                countTotalComments = [NSString stringWithFormat:@"%d",value];
				[self DiscoverPostToserver:str_SelectedUserId];
			}
		}
	}
}


#pragma mark - media player

// Play the Voice through Audio Player
- (void)act_GoToAudioPlayer:(UIButton*)sender
{
	
    NSString* resourcePath = [NSString stringWithFormat:@"%@",[arr_PostMediaFile objectAtIndex:sender.tag]]; //your url
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

// Play the Video through Audio Player
- (void)act_GoToVideoPlayer:(UIButton*)sender
{
	NSLog(@"%@",[arr_PostMediaFile objectAtIndex:sender.tag]);
    NSString* resourcePath = [NSString stringWithFormat:@"%@",[arr_PostMediaFile objectAtIndex:sender.tag]];
    
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
