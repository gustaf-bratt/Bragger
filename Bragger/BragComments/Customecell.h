//
//  Customecell.h
//  Assignment 26
//
//  Created by user on 8/22/13.
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface Customecell : UITableViewCell


@property (weak, nonatomic) IBOutlet UILabel *lbl_CommentTime;
@property(strong,nonatomic) IBOutlet UILabel * lbl_Title;
@property(strong,nonatomic) IBOutlet UILabel * lbl_Subtitle;
@property(strong,nonatomic) IBOutlet UILabel * lbl_AddSubtitle;
@property(strong,nonatomic) IBOutlet UIImageView *img_Icons;

+(NSString *)reuseidentifier;

@end
