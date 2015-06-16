//
//  Item.h
//  Reminders
//
//  Created by 陈旭 on 5/29/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Item : NSObject

@property (nonatomic, copy) NSString *text;
@property (nonatomic, assign) BOOL isChecked;
@property (nonatomic, retain) NSNumber * photoId;
@property (nonatomic, copy) NSDate *dueDate;
@property (nonatomic, assign) BOOL shouldRemind;
@property (nonatomic, assign) NSInteger itemId;


- (void)toggleChecked;

+ (NSInteger)nextPhotoId;
+ (NSInteger)nextItemId;

- (BOOL)hasPhoto;
- (NSString *)photoPath;
- (UIImage *)photoImage;
- (void)removePhotoFile;

@end
