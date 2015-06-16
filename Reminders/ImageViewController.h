//
//  ImageViewController.h
//  Reminders
//
//  Created by 陈旭 on 6/15/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIScrollView *scrollView;

@property (nonatomic, weak) IBOutlet UIImageView *fullScreenImageView;

- (void)showFullImageInViewController:(UIViewController *)controller
                            withImage:(UIImage *)image;

@end
