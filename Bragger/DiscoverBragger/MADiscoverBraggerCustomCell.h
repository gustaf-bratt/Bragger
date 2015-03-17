//
//  MADiscoverBraggerCustomCell.h
//  Bragger
//
//  Created by GaoShen on 2/13/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MADiscoverBraggerCustomCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *img_FromPostMediaFile;
@property (weak, nonatomic) IBOutlet UIButton *btn_GoToBraggersProfile;
@property (weak, nonatomic) IBOutlet UIButton *btn_PostLike;
@property (weak, nonatomic) IBOutlet UIButton *btn_PostReBrag;
@property (weak, nonatomic) IBOutlet UIButton *btn_ShowOff;

@property (weak, nonatomic) IBOutlet UILabel *lbl_PostTitle;
@property (weak, nonatomic) IBOutlet UILabel *lbl_PostedTime;
@property (weak, nonatomic) IBOutlet UILabel *lbl_ShowLikeCount;
@property (weak, nonatomic) IBOutlet UILabel *lbl_ShowReBragCount;
@property (weak, nonatomic) IBOutlet UILabel *lbl_ShowDisLikeCount;



@end
