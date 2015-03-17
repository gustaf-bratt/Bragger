//
//  MABraggingStreamCustomCell.m
//  Bragger
//
//  Created by Muthu Sabari on 2/13/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//
#import "MABraggingStreamViewController.h"
#import "MABraggingStreamCustomCell.h"

@implementation MABraggingStreamCustomCell
@synthesize lbl_TotalLike4Post,lbl_TotalShowOff4Post,lbl_TotalReBrags4Post,btn_BraggerName,lbl_LocationLabel,lbl_TitleLabel;
@synthesize txt_CommentBragText,btn_PostLike,btn_Follower,img_ToUserImage,btn_ShowOff,btn_Comment,img_FromPostMediaFile;
@synthesize lbl_PostTime,btn_imgFromPostMediaFile;
@synthesize btn_LikeInVw;
@synthesize btn_Rebrag;
@synthesize btn_RebragVw;
@synthesize btn_ShowOffVw;
@synthesize lbl_HashTag;
@synthesize img_PinLocation;
@synthesize lbl_WritePost;
@synthesize btn_Flag;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
	{
		
		NSLog(@"reuse:%@",reuseIdentifier);
        // Initialization code
        //txt_CommentBragText.delegate=self;
		
		// location
		lbl_LocationLabel = [[UILabel alloc]initWithFrame:CGRectMake(88, 40, 209, 16)];
		lbl_LocationLabel.font = [UIFont systemFontOfSize:8.0];
		lbl_LocationLabel.textColor = [UIColor blackColor];
		[self.contentView addSubview:lbl_LocationLabel];
		
		// user name btn
		btn_BraggerName = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn_BraggerName setFrame:CGRectMake(77, 13, 181, 24)];
		[btn_BraggerName setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
		btn_BraggerName.titleLabel.font = [UIFont systemFontOfSize:17.0];
		btn_BraggerName.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
		[self.contentView addSubview:btn_BraggerName];
		 
		// user flag btn
		btn_Flag = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn_Flag setFrame:CGRectMake(273, 9, 20, 20)];
		[btn_Flag setBackgroundImage:[UIImage imageNamed:@"arrow"] forState:UIControlStateNormal];
		[self.contentView addSubview:btn_Flag];
		

		
		
		// user profile photo
		img_ToUserImage = [[UIImageView alloc]initWithFrame:CGRectMake(8, 9, 60, 60)];
    	[self.contentView addSubview:img_ToUserImage];
		
		// image pin location
		// label post time
		//NSLog(@"te:%f",img_ToUserImage.frame.size.height + img_ToUserImage.frame.origin.y);
		lbl_PostTime = [[UILabel alloc]initWithFrame:CGRectMake(13, img_ToUserImage.frame.size.height + img_ToUserImage.frame.origin.y+5, 70, 14)];
		lbl_PostTime.font = [UIFont systemFontOfSize:8.0];
		lbl_PostTime.textColor = [UIColor lightGrayColor];
		[self.contentView addSubview:lbl_PostTime];

		img_PinLocation = [[UIImageView alloc]initWithFrame:CGRectMake(74, 43, 10, 12)];
        
		[img_PinLocation setImage:[UIImage imageNamed:@"pointer_icon.png"]];
		[self.contentView addSubview:img_PinLocation];
        
		// follow button
		btn_Follower = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn_Follower setFrame:CGRectMake(79, 63, 53, 26)];
        
		[btn_Follower setBackgroundImage:[UIImage imageNamed:@"bragger_Profile_Follow_Button.png"] forState:UIControlStateNormal];
		[self.contentView addSubview:btn_Follower];
		
		// btn post media file
		btn_imgFromPostMediaFile = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn_imgFromPostMediaFile setFrame:CGRectMake(0, 95, 299, 141)];
		[self.contentView addSubview:btn_imgFromPostMediaFile];
		
		// image post media file
		if ([reuseIdentifier isEqualToString:@"MABraggingStreamCustomCell"])
		{
			img_FromPostMediaFile = [[UIImageView alloc]initWithFrame:CGRectMake(0, 95, 299, 299)];
			[self.contentView addSubview:img_FromPostMediaFile];
		}
		else
		{
			img_FromPostMediaFile = [[UIImageView alloc]initWithFrame:CGRectMake(0, 95, 299, 120)];//120
			[self.contentView addSubview:img_FromPostMediaFile];
			
			lbl_WritePost = [[UILabel alloc]initWithFrame:CGRectMake(10, -25, 280, 120)];
			[lbl_WritePost setLineBreakMode:NSLineBreakByWordWrapping];
			[lbl_WritePost setNumberOfLines:0];
			[lbl_WritePost setTextColor:[UIColor whiteColor]];
			[img_FromPostMediaFile addSubview:lbl_WritePost];
		}
        img_FromPostMediaFile.backgroundColor = [UIColor colorWithWhite:0.2f alpha:1.0f];
		img_FromPostMediaFile.contentMode = UIViewContentModeScaleAspectFit;
		
		// btn like view
		btn_LikeInVw = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn_LikeInVw setFrame:CGRectMake(0, img_FromPostMediaFile.frame.size.height + img_FromPostMediaFile.frame.origin.y - 58.0, 99, 58)];
		[btn_LikeInVw setBackgroundImage:[UIImage imageNamed:@"like.png"] forState:UIControlStateNormal];
		[self.contentView addSubview:btn_LikeInVw];

		// label total like
		lbl_TotalLike4Post = [[UILabel alloc]initWithFrame:CGRectMake(29, img_FromPostMediaFile.frame.size.height + img_FromPostMediaFile.frame.origin.y - 16.0*1.5, 74, 16)];
		lbl_TotalLike4Post.font = [UIFont systemFontOfSize:13.0];
		lbl_TotalLike4Post.textColor  = [UIColor whiteColor];
		[self.contentView addSubview:lbl_TotalLike4Post];
		
		// btn rebrag view
		btn_RebragVw = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn_RebragVw  setFrame:CGRectMake(98, img_FromPostMediaFile.frame.size.height + img_FromPostMediaFile.frame.origin.y - 58.0, 101, 58)];
		[btn_RebragVw  setBackgroundImage:[UIImage imageNamed:@"rebrags.png"] forState:UIControlStateNormal];
		[self.contentView addSubview:btn_RebragVw ];
		
		// label total rebrag
		lbl_TotalReBrags4Post = [[UILabel alloc]initWithFrame:CGRectMake(98 + 22, img_FromPostMediaFile.frame.size.height + img_FromPostMediaFile.frame.origin.y - 16.0*1.5, 74, 16)];
		lbl_TotalReBrags4Post.font = [UIFont systemFontOfSize:13.0];
		lbl_TotalReBrags4Post.textColor  = [UIColor whiteColor];
		[self.contentView addSubview:lbl_TotalReBrags4Post];
		
		// btn showoff view
		btn_ShowOffVw = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn_ShowOffVw  setFrame:CGRectMake(198, img_FromPostMediaFile.frame.size.height + img_FromPostMediaFile.frame.origin.y - 58.0, 103, 58)];
		//[btn_ShowOffVw  setBackgroundImage:[UIImage imageNamed:@"rebrags.png"] forState:UIControlStateNormal];
        [btn_ShowOffVw  setBackgroundImage:[UIImage imageNamed:@"showoff.png"] forState:UIControlStateNormal];
        
		[self.contentView addSubview:btn_ShowOffVw];
		
		// label total showoff
		lbl_TotalShowOff4Post = [[UILabel alloc]initWithFrame:CGRectMake(209, img_FromPostMediaFile.frame.size.height + img_FromPostMediaFile.frame.origin.y - 16.0*1.5, 100, 16)];
		lbl_TotalShowOff4Post.font = [UIFont systemFontOfSize:13.0];
		lbl_TotalShowOff4Post.textColor  = [UIColor whiteColor];
		[self.contentView addSubview:lbl_TotalShowOff4Post];
		
		// title label
		lbl_TitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(11, img_FromPostMediaFile.frame.size.height + img_FromPostMediaFile.frame.origin.y, 300, 25)];
		lbl_TitleLabel.font = [UIFont boldSystemFontOfSize:11.0];//[UIFont fontWithName:@"Helvetica Neue Bold" size:11.0];
		lbl_TitleLabel.textColor = [UIColor darkGrayColor];
		[self.contentView addSubview:lbl_TitleLabel];

		

		// label hash tag
		lbl_HashTag = [[UILabel alloc]initWithFrame:CGRectMake(99, lbl_TitleLabel.frame.size.height + lbl_TitleLabel.frame.origin.y - 17.0 / 2.0, 93, 17)];
		lbl_HashTag.font = [UIFont systemFontOfSize:8.0];
		lbl_HashTag.textColor = [UIColor lightGrayColor];
		[self.contentView addSubview:lbl_HashTag];
		
		// btn post like
		
		btn_PostLike = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn_PostLike setFrame:CGRectMake(223, lbl_TitleLabel.frame.size.height + lbl_TitleLabel.frame.origin.y-5, 17, 17)];
		[btn_PostLike setBackgroundImage:[UIImage imageNamed:@"bragger_Profile_Like_button.png"] forState:UIControlStateNormal];
		[self.contentView addSubview:btn_PostLike];
		
		// btn post rebrag
		
		btn_Rebrag = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn_Rebrag setFrame:CGRectMake(244, lbl_TitleLabel.frame.size.height + lbl_TitleLabel.frame.origin.y-5, 20, 17)];
		[btn_Rebrag setBackgroundImage:[UIImage imageNamed:@"bragger_Profile_Rebrags_button.png"] forState:UIControlStateNormal];
		[self.contentView addSubview:btn_Rebrag];
		
		// btn post show off
		
		btn_ShowOff = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn_ShowOff setFrame:CGRectMake(269, lbl_TitleLabel.frame.size.height + lbl_TitleLabel.frame.origin.y-5, 20, 17)];
		[btn_ShowOff setBackgroundImage:[UIImage imageNamed:@"bragger_Profile_Showoff_button.png"] forState:UIControlStateNormal];
		[self.contentView addSubview:btn_ShowOff];

		/*
		// text box image view
		
		UIImageView *img_ForTextBox = [[UIImageView alloc]initWithFrame:CGRectMake(7, lbl_TitleLabel.frame.size.height / 2 + lbl_TitleLabel.frame.origin.y  + 20, 284, 30)];
		[img_ForTextBox setImage:[UIImage imageNamed:@"textBox1.png"]];
		[self.contentView addSubview:img_ForTextBox];
		
		

		// text field
		txt_CommentBragText = [[UITextField alloc] initWithFrame:CGRectMake(19, lbl_TitleLabel.frame.size.height / 2 + lbl_TitleLabel.frame.origin.y  + 25, 263, 25)];
		txt_CommentBragText.borderStyle = UITextBorderStyleNone;
		txt_CommentBragText.font = [UIFont systemFontOfSize:12];
		txt_CommentBragText.placeholder = @"Comment on this brag";
		txt_CommentBragText.autocorrectionType = UITextAutocorrectionTypeNo;
		txt_CommentBragText.keyboardType = UIKeyboardTypeDefault;
		txt_CommentBragText.returnKeyType = UIReturnKeyDone;
		txt_CommentBragText.clearButtonMode = UITextFieldViewModeWhileEditing;
		txt_CommentBragText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		txt_CommentBragText.delegate = self;
		[self.contentView addSubview:txt_CommentBragText];
		
		NSLog(@"he:%f",img_ForTextBox.frame.size.height  + img_ForTextBox.frame.origin.y);
*/
			
		// btn comment
		btn_Comment = [UIButton buttonWithType:UIButtonTypeCustom];
		[btn_Comment setFrame:CGRectMake(0, lbl_TitleLabel.frame.size.height + lbl_TitleLabel.frame.origin.y-5, 94, 20)];
		[btn_Comment setTitleColor:[UIColor colorWithRed:0.0 green:112.0/255.0 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
		[btn_Comment setTitle:@"0 comments" forState:UIControlStateNormal];
        [btn_Comment setImage:[UIImage imageNamed:@"bragger_Profile_Comment_button.png"] forState:UIControlStateNormal];
		btn_Comment.titleLabel.font = [UIFont systemFontOfSize:8.0];
		[self.contentView addSubview:btn_Comment];
/*
		UIImageView *img_ForComments = [[UIImageView alloc]initWithFrame:CGRectMake(20, img_ForTextBox.frame.size.height  + img_ForTextBox.frame.origin.y + 15, 19, 19)];
		[img_ForComments setImage:[UIImage imageNamed:@"bragger_Profile_Comment_button.png"]];
		[self.contentView addSubview:img_ForComments];
*/
        
    }
    return self;
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

+(NSString*)reuseIdentifier
{
    return @"CustomCellIdentifier";
}
-(IBAction)HdKeyboard:(id)sender
{
    //[txt_CommentBragText resignFirstResponder];
    
}
- (void) animateTextView:(BOOL) up
{
    const int movementDistance =120.0; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    int movement= movement = (up ? -movementDistance : movementDistance);
    UITableView *view;
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    view.frame = CGRectOffset(view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self animateTextView : YES];
}
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	//[txt_CommentBragText resignFirstResponder];
    [self  animateTextView :NO];
}



@end
