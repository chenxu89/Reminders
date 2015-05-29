//
//  ListViewController.h
//  Reminders
//
//  Created by 陈旭 on 5/28/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ListHeadView;

@interface ListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate,UITextViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableview;

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *itemsCountLabel;
@property (nonatomic, weak) IBOutlet UIButton *doneOrEditButton;

- (IBAction)clickCheckButton:(id)sender;
- (IBAction)doneOrEdit:(id)sender;

@end
