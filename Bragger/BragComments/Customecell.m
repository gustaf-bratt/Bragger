//
//  Customecell.m
//  Assignment 26
//
//  Created by user on 8/22/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Customecell.h"


@implementation Customecell
@synthesize lbl_Title,lbl_Subtitle,lbl_AddSubtitle,img_Icons,lbl_CommentTime;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+(NSString *)reuseidentifier
{
    return @"CustomeCellIdentifier";
}

@end
