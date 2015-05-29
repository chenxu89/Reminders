//
//  List.m
//  Reminders
//
//  Created by 陈旭 on 5/28/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import "List.h"
#import "Item.h"

@implementation List

- (NSUInteger)countUncheckedItems
{
    NSUInteger count = 0;
    for (Item *item in self.items) {
        if (!item.isChecked) {
            count += 1;
        }
    }
    self.uncheckedItemsCount = count;
    return self.uncheckedItemsCount;
}

@end
