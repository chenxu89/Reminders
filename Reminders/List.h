//
//  List.h
//  Reminders
//
//  Created by 陈旭 on 5/28/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface List : NSObject


@property (nonatomic, copy) NSString *name;
@property (nonatomic, assign) NSUInteger uncheckedItemsCount;
@property (nonatomic, assign) BOOL isEditting;
@property (nonatomic, strong) NSMutableArray *items;

- (NSUInteger)countUncheckedItems;

@end
