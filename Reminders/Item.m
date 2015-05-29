//
//  Item.m
//  Reminders
//
//  Created by 陈旭 on 5/29/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import "Item.h"

@implementation Item

- (void)toggleChecked
{
    self.isChecked = !self.isChecked;
}

@end
