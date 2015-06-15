//
//  ListViewController.h
//  Reminders
//
//  Created by 陈旭 on 5/28/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemDetailViewController.h"

@class ListHeadView;

@interface ListViewController : UIViewController <ItemDetailViewControllerDelegate>

@property (nonatomic, retain) IBOutlet UIView *myViewFromNib;
@property (nonatomic, weak) IBOutlet UIImageView *imageviewFromNib;

@end
