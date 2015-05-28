//
//  ListTitleCell.h
//  Reminders
//
//  Created by 陈旭 on 5/28/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListTitleCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *listTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *itemsCountLabel;
@property (nonatomic, weak) IBOutlet UIButton *listStatusButton;


@end
