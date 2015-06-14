//
//  DetailViewController.h
//  Reminders
//
//  Created by 陈旭 on 6/5/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Item;

@interface ItemDetailViewController : UITableViewController

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, assign) BOOL allowEditPhoto;
@property (nonatomic, strong) Item *item;

- (IBAction)done:(id)sender;

@end
