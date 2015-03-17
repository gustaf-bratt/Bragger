//
//  MADiscoverBraggerViewController.h
//  Bragger
//
//  Created by GaoShen on 2/2/14.
//  Copyright (c) 2014 Nagarjunan. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MADiscoverBraggerCustomCell.h"
#import "MBProgressHUD.h"

@interface MADiscoverBraggerViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate, MBProgressHUDDelegate, UISearchBarDelegate>
{
    MBProgressHUD *HUD;    
}
@property (strong,nonatomic) NSMutableArray *filteredBragger;
@property (strong,nonatomic) NSMutableArray *filteredBraggerIndex;
@property BOOL isFiltered;

@property (weak, nonatomic) IBOutlet UISegmentedControl *seeg_DiscoverSegmentation;
@property (weak, nonatomic) IBOutlet UICollectionView *coll_DiscoverBragger;
@property (weak, nonatomic) IBOutlet UISearchBar *mainSearchBar;

- (IBAction)act_Braggers:(id)sender;
- (IBAction)act_ShareBrag:(id)sender;
- (IBAction)act_BackDiscover:(id)sender;
- (IBAction)act_Bragging:(id)sender;
- (IBAction)act_ChangeSeg:(id)sender;
- (IBAction)act_Settings:(id)sender;



@end
