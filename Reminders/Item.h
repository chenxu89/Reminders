//
//  Item.h
//  Reminders
//
//  Created by 陈旭 on 5/29/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Item : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) BOOL isChecked;

- (void)toggleChecked;

@end
