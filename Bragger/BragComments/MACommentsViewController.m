//
//  MACommentsViewController.m
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
#import "MACommentsViewController.h"
#import "MABraggerLoginViewController.h"
#import "MABraggingStreamViewController.h"
#import "Customecell.h"
#import "MABraggerProfileViewController.h"
#import "MASingleton.h"
#import "Constant.h"

@interface MACommentsViewController ()
{
     BOOL myLocalProperty;
     NSString *userId;
     NSString *sessionId;
     NSMutableArray *commenTedByUserIdArr;
     NSMutableArray *commentTextArr;
     NSMutableArray *commentDateArr;
     NSMutableArray *commentMediaFileArr;
     NSMutableArray *commentedUserPhoto;
 
     UIImagePickerController *img_PickerController;
     UIImage *imageForPhotComment;
     int noOfIndexInTable;
	Reachability *reachability;
	UIAlertView *alert4Connectivity;
	BOOL isAlertShowing;

}

@end

@implementation MACommentsViewController
@synthesize txt_COmmentBragText,tbl_Comment,myProperty,str_RealName,str_Location,str_UserImagePath,img_PostedImage;
@synthesize lbl_Location,lbl_RealName,img_UserImage,lbl_TotalPost4Like,lbl_TotalShowOff,str_TotalPost4Like,str_TotalShowOff,postId,PostOwnerUserId;
@synthesize str_postedImageUrl, str_TotalRebrag,lbl_Rebrag, isFollowing, btn_Follow, likeBtn, showOffBtn, rebragBtn, likeBtnSmall,showOffBtnSmall, rebragBtnSmall;
@synthesize img_PinLocation,str_PostTitle,lbl_PostTitle,str_HashTag,lbl_HashTag,str_Like,str_Rebrag,str_ShowOff;

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
	
    noOfIndexInTable = 0;
    userId = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_id"];
    sessionId = [[NSUserDefaults standardUserDefaults] objectForKey:@"session_id"];
    lbl_RealName.text = str_RealName;
    lbl_PostTitle.text = str_PostTitle;
    if ([str_HashTag isEqual:[NSNull null]])
    {
    lbl_HashTag.text = @"";
    }
    else
        lbl_HashTag.text = str_HashTag;
 
    
   if ([str_Location isEqual:[NSNull null]] || [str_Location isEqual:@"(null)"])
   {
     lbl_Location.text = @"";
     img_PinLocation.hidden = YES;
   }
   else
     lbl_Location.text = str_Location;
   
//   if ([str_TotalPost4Like isEqual:[NSNull null]])
//      lbl_TotalPost4Like.text = @"0";
//   else
//   {
    if ([str_Like  isEqualToString:@"yes"])
    {
     likeBtn.userInteractionEnabled = YES;
     showOffBtn.userInteractionEnabled = YES;
     likeBtnSmall.userInteractionEnabled = NO;
     showOffBtnSmall.userInteractionEnabled = NO;
     [likeBtnSmall setImage:[UIImage imageNamed:@"bragger_Profile_Like_button_blue.png"] forState:UIControlStateNormal];
    }
    lbl_TotalPost4Like.text = str_TotalPost4Like;
//   }
 
// if ([str_TotalShowOff isEqual:[NSNull null]])
//  lbl_TotalShowOff.text = @"0";
// else
// {
   
  if ([str_ShowOff  isEqualToString:@"yes"])
  {
   likeBtn.userInteractionEnabled = YES;
   showOffBtn.userInteractionEnabled = YES;
   likeBtnSmall.userInteractionEnabled = NO;
   showOffBtnSmall.userInteractionEnabled = NO;
   [showOffBtnSmall setImage:[UIImage imageNamed:@"bragger_Profile_Showoff_blue_button.png"] forState:UIControlStateNormal];
  }
  lbl_TotalShowOff.text = str_TotalShowOff;

// }
 
// if ([str_TotalRebrag isEqual:[NSNull null]])
//  lbl_Rebrag.text = @"0";
// else
// {
  if ([str_Rebrag  isEqualToString:@"yes"] )
  {
  rebragBtn.userInteractionEnabled = NO;
   rebragBtnSmall.userInteractionEnabled = NO;
    [rebragBtnSmall setImage:[UIImage imageNamed:@"bragger_Profile_Rebrags_blue_button.png"] forState:UIControlStateNormal];
  }
	
	if ([PostOwnerUserId isEqualToString:userId])
	{
		rebragBtn.userInteractionEnabled = NO;
		rebragBtnSmall.userInteractionEnabled = NO;
	}
	
	
  lbl_Rebrag.text = str_TotalRebrag;
// }

 if (isFollowing == YES)
 {
	 [btn_Follow setImage:[UIImage imageNamed:@"bragger_Profile_Unfollow_Button"] forState:UIControlStateNormal];
 }
  
    img_UserImage.layer.cornerRadius = 56/2;
    img_UserImage.layer.masksToBounds = YES;
    img_UserImage.layer.rasterizationScale = [UIScreen mainScreen].scale;
    img_UserImage.layer.shouldRasterize = YES;
    img_UserImage.clipsToBounds = YES;
    
    if (![str_postedImageUrl isEqual:[NSNull null]])
    {
        NSURL *url_Image = [NSURL URLWithString:str_UserImagePath];
        NSData *data_Image = [NSData dataWithContentsOfURL:url_Image];
        UIImage *img_UserImage1 = [[UIImage alloc] initWithData:data_Image];
         img_UserImage.image = img_UserImage1;

    }
        if (![str_postedImageUrl isEqual:[NSNull null]])
    {
     NSURL *url_PostedImage = [NSURL URLWithString:str_postedImageUrl];
     NSData *data_PostedImage = [NSData dataWithContentsOfURL:url_PostedImage];
     UIImage *img_PostedImage1 = [[UIImage alloc] initWithData:data_PostedImage];
     img_PostedImage.image = img_PostedImage1;

    }
    txt_COmmentBragText.delegate = self;
    [self viewPostComment:postId];
 
    tbl_Comment.delegate = self;
    tbl_Comment.dataSource = self;
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TextView
- (void) animateTextView:(BOOL) up
{
    const int movementDistance =170.0; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    int movement= movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

-(IBAction)HdKeyboard:(id)sender
{
    [txt_COmmentBragText resignFirstResponder];
}


#pragma mark - textfield delegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextView : YES];
   
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    [self  animateTextView :NO];
}
#pragma mark - back
- (IBAction)act_Back:(id)sender
{

    g_isCommentedRow = -1;
    [self dismissViewControllerAnimated:YES completion:nil];

}

#pragma mark - table view delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return noOfIndexInTable;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Customecell   *cell = (Customecell*) [tableView dequeueReusableCellWithIdentifier:[Customecell reuseidentifier]];
    if(cell == nil)
    {
        [[NSBundle mainBundle] loadNibNamed:@"Customecell" owner:self options:nil];
        cell = _newcustom_Cell;
        _newcustom_Cell = nil;
    }
 cell.img_Icons.image = [UIImage imageNamed:@"Image_Base-1.png"];
 cell.img_Icons.layer.cornerRadius = 45/2;
 cell.img_Icons.layer.masksToBounds = YES;

 dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,  0ul);
 dispatch_async(queue, ^{
  NSString *str_ImageUrl = [NSString stringWithFormat:@"%@",[commentedUserPhoto objectAtIndex:indexPath.row]];
  NSURL *url_Image = [NSURL URLWithString:str_ImageUrl];
  NSData *imgData = [NSData dataWithContentsOfURL:url_Image];
  if (imgData) {
   UIImage *image = [UIImage imageWithData:imgData];
   if (image) {
    dispatch_async(dispatch_get_main_queue(), ^
                   {
                    cell.img_Icons.image = image;
                   });
   }
  }
 });
    cell.lbl_Title.text = (NSString*)[commentTextArr objectAtIndex:indexPath.row];
    cell.lbl_CommentTime.text = [MASingleton getCommentTime:[commentDateArr objectAtIndex:indexPath.row]];
  if (![(NSString *)[commentMediaFileArr objectAtIndex:indexPath.row] isEqualToString:@"invalid file"])
  {
   CGRect frameTitle = cell.lbl_Title.frame;
   frameTitle.origin = CGPointMake(80, 20);//100
   cell.lbl_Title.frame = frameTitle;
   CGRect frameTime = cell.lbl_CommentTime.frame;
   frameTime.origin = CGPointMake(80, 30);//125
   cell.lbl_CommentTime.frame = frameTime;

   dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH,  0ul);
   dispatch_async(queue, ^{
    NSString *str_ImageUrl = [NSString stringWithFormat:@"%@",[commentMediaFileArr objectAtIndex:indexPath.row]];
    NSURL *url_Image = [NSURL URLWithString:str_ImageUrl];
    NSData *imgData = [NSData dataWithContentsOfURL:url_Image];
    if (imgData) {
     UIImage *image = [UIImage imageWithData:imgData];
     if (image) {
      dispatch_async(dispatch_get_main_queue(), ^
                     {
                      UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(80, 5, 100, 100)];
                      [cell addSubview:imgView];
                      imgView.image = image;
                     });
     }
    }
   });

  }
 
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
 if ([(NSString *)[commentMediaFileArr objectAtIndex:indexPath.row] isEqualToString:@"invalid file"])
  return 67.5;
 else
   return 150.0;
}

#pragma mark - show posted comment
-(void)viewPostComment:(NSString *)postId1
{
 NSString *urlAsString = GETAPILINK(@"postwebs/ViewPostComments/");
 urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];
 urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];
 urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&post_id=%@",postId1]];
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
   NSLog(@"Successfully deserialized...");
   
   NSLog(@"Deserialized JSON Dictionary = %@",jsonObject);
   if ([(NSString *)[jsonObject valueForKey:@"jsonstatus"]  isEqual: @"fail"] )
   {
    noOfIndexInTable = 0;
   }
   else
   {
   noOfIndexInTable = [jsonObject count];
   commenTedByUserIdArr = (NSMutableArray *)[jsonObject valueForKey:@"commented_by_user_id"];
   commentTextArr = (NSMutableArray *)[jsonObject valueForKey:@"comment_text"];
   commentDateArr = (NSMutableArray *)[jsonObject valueForKey:@"comment_date"];
   commentMediaFileArr = (NSMutableArray *)[jsonObject valueForKey:@"comment_mediafile"];
   commentedUserPhoto = (NSMutableArray *)[jsonObject valueForKey:@"user_image"];
   NSLog(@"%@",commenTedByUserIdArr);
   }
   [tbl_Comment reloadData];
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

#pragma mark - post comment

-(void)postCommentToServer:(NSString *)comment_txt postId:(NSString *)postId1
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
         urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&post_id=%@",postId1]];
         urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&comment_text=%@",comment_txt]];
         urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&mediatype=photo"]];
         NSString *properlyEscapedURL = [urlAsString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
         NSURL *url = [NSURL URLWithString:properlyEscapedURL];
         NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
         [request setURL:url];
         [request setHTTPMethod:@"POST"];
         
             
         CGImageRef cgref = [imageForPhotComment CGImage];
         CIImage *cim = [imageForPhotComment CIImage];
         NSData *data_PostingImage = [[NSData alloc]init];;
         if (cim == nil && cgref == NULL)
         {
              
         }
        else
         {
            
             
             data_PostingImage = UIImagePNGRepresentation(imageForPhotComment);
             NSString *boundary = @"---------------------------14737809831466499882746641449";
             NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
             [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
             
             
             NSMutableData *body = [NSMutableData data];
             [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
             [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"post_mediafile\"; filename=\"test.png\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
             [body appendData:[@"Content-Type: application/octet-stream\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
             [body appendData:[NSData dataWithData:data_PostingImage]];
             [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
             [request setHTTPBody:body];


         }
             
         NSURLResponse *response = nil;
         NSError *error = nil;
         //  NSOperationQueue *queue = [[NSOperationQueue alloc] init];
         NSData *data = [NSURLConnection sendSynchronousRequest:request
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
                   
                   NSLog(@"Deserialized JSON Dictionary = %@",jsonObject);
                   
                    if ([[jsonObject objectForKey:@"jsonstatus" ] isEqualToString:@"fail"])
                    {
                       UIAlertView *alert_CommentPost = [[UIAlertView alloc] initWithTitle:@"Bragger" message:[jsonObject valueForKey:@"message"] delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
                       [alert_CommentPost show];
                    }
                   [self viewPostComment:postId];
                   txt_COmmentBragText.text = nil;
                   _img_PostComment.image = nil;
              }
              else if (error != nil)
              {
                  NSLog(@"An error happened while deserializing the JSON data.%@",error);
              }
        }
        else if ([data length] == 0 && error == nil){
          NSLog(@"Nothing was downloaded.");
        }
        else if (error != nil)
        {
            NSLog(@"Error happened = %@", error);
        }
    }
}

- (IBAction)act_PhotoComment:(id)sender
{
 
 img_PickerController = [[UIImagePickerController alloc] init];
 img_PickerController.delegate = self;
 img_PickerController.allowsEditing = YES;
 img_PickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
 [self presentViewController:img_PickerController animated:YES completion:NULL];
 
}

- (IBAction)act_PostComment:(id)sender
{
    HUD = [[MBProgressHUD alloc] initWithView:self.view];
    [self.view addSubview:HUD];
    [self.view bringSubviewToFront:HUD];
    HUD.dimBackground = YES;
    // Regiser for HUD callbacks so we can remove it from the window at the right time
    HUD.delegate = self;
    // Show the HUD while the provided method executes in a new thread
    [HUD showWhileExecuting:@selector(gotoStreamView) onTarget:self withObject:Nil animated:YES];
}

- (void) gotoStreamView
{
    [self postCommentToServer:txt_COmmentBragText.text postId:postId];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Image Picker Delegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
 _img_PostComment.hidden = NO;
 _img_PostComment.image = image;
 imageForPhotComment = _img_PostComment.image;
 [picker dismissModalViewControllerAnimated:YES];
 
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
 
 [picker dismissViewControllerAnimated:YES completion:nil];
 
}

 #pragma mark - follow user

- (IBAction)act_follow:(id)sender
{
	if (isFollowing == NO)
	{
		NSString *urlAsString = GETAPILINK(@"memberwebs/AddFollowers/");
		
		urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];
		urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];
		urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&to_user_id=%@",PostOwnerUserId]];
		
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
					else
					{
						[btn_Follow setImage:[UIImage imageNamed:@"bragger_Profile_Unfollow_Button"] forState:UIControlStateNormal];
						isFollowing = YES;
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
		urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&to_user_id=%@",PostOwnerUserId]];
		
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
					else
					{
						[btn_Follow setImage:[UIImage imageNamed:@"bragger_Profile_Follow_Button.png"] forState:UIControlStateNormal];
						isFollowing = NO;
					}
					
				}
			}
		}
		
	}

	
}

#pragma mark - like,showoff and rebrag a post
- (IBAction)act_like:(id)sender
{
 [self likeOrDislikePostServer:@"yes"];
}

- (IBAction)act_ShowOff:(id)sender
{
 [self likeOrDislikePostServer:@"no"];
}

-(void)likeOrDislikePostServer:(NSString *)likeOrDisLike
{
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
        NSNumber *tempNum = (NSNumber *)str_TotalPost4Like;
        int value = [tempNum intValue];
        value++;
       likeBtn.userInteractionEnabled = NO;
       showOffBtn.userInteractionEnabled = NO;
       likeBtnSmall.userInteractionEnabled = NO;
       showOffBtnSmall.userInteractionEnabled = NO;
       [likeBtnSmall setImage:[UIImage imageNamed:@"bragger_Profile_Like_button_blue.png.png"] forState:UIControlStateNormal];
       lbl_TotalPost4Like.text = [NSString stringWithFormat:@"%d",value];
      
     }
     else
     {
        NSNumber *tempNum = (NSNumber *)str_TotalShowOff;
        int value = [tempNum intValue];
        value++;
      likeBtn.userInteractionEnabled = NO;
      showOffBtn.userInteractionEnabled = NO;
      likeBtnSmall.userInteractionEnabled = NO;
      showOffBtnSmall.userInteractionEnabled = NO;
      [showOffBtnSmall setImage:[UIImage imageNamed:@"bragger_Profile_Showoff_blue_button.png"] forState:UIControlStateNormal];
      lbl_TotalShowOff.text = [NSString stringWithFormat:@"%d",value];

      
      }
    }
    }
  }
 }
}

- (IBAction)act_likeSmall:(id)sender
{
 [self act_like:nil];
}

- (IBAction)act_RebragSmall:(id)sender
{
 [self act_Rebrag:nil];
}

- (IBAction)actShowOffSmall:(id)sender
{
 [self act_ShowOff:nil];
}

- (IBAction)act_Rebrag:(id)sender
{
     NSString *urlAsString = GETAPILINK(@"postwebs/RePost/");
     urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"?user_id=%@",userId]];
     
     urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&session_id=%@",sessionId]];
     urlAsString = [urlAsString stringByAppendingString:[NSString stringWithFormat:@"&post_id=%@",postId]];
     
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
                         NSNumber *tempNum = (NSNumber *)str_TotalRebrag;
                         int value = [tempNum intValue];
                         value++;
                         rebragBtn.userInteractionEnabled = NO;
                         rebragBtnSmall.userInteractionEnabled = NO;
                         [rebragBtnSmall setImage:[UIImage imageNamed:@"bragger_Profile_Rebrags_blue_button.png"] forState:UIControlStateNormal];
                         lbl_Rebrag.text = [NSString stringWithFormat:@"%d",value];
                    }
                    NSLog(@"Deserialized JSON Dictionary = %@",
                          deserializedDictionary);
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
