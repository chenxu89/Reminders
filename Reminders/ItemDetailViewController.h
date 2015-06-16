//
//  DetailViewController.h
//  Reminders
//
//  Created by 陈旭 on 6/5/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import <UIKit/UIKit.h>
@class Item;
@class ItemDetailViewController;

@protocol ItemDetailViewControllerDelegate <NSObject>

- (void)itemDetailViewControllerDidCancel:(ItemDetailViewController *)controller;

- (void)itemDetailViewController:(ItemDetailViewController *)controller
      didFinishEditingItem:(Item *)item;

@end

@interface ItemDetailViewController : UITableViewController

@property (nonatomic, weak) IBOutlet UIImageView *imageView;
@property (nonatomic, assign) BOOL allowEditPhoto;
@property (nonatomic, strong) Item *item;
@property (nonatomic, weak) IBOutlet UISwitch *reminderSwitchControl;
@property (nonatomic, weak) IBOutlet UILabel *dueDateLabel;

@property (nonatomic, weak) id <ItemDetailViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

@end
