//
//  MABraggerProfileCustomCell.m
//  Bragger
//
//  Created by Muthu Sabari on 2/14/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import "MABraggerProfileCustomCell.h"

@implementation MABraggerProfileCustomCell
@synthesize txt_CommentBragText;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
     txt_CommentBragText.delegate = self;
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
 [txt_CommentBragText resignFirstResponder];
 
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
 
 
 [self  animateTextView :NO];
 
}

@end
