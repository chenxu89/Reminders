//
//  ImageViewController.m
//  Reminders
//
//  Created by 陈旭 on 6/15/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIGestureRecognizerDelegate, UIScrollViewAccessibilityDelegate>


@end

@implementation ImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor blackColor];
    
    //tap to close
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
    gestureRecognizer.cancelsTouchesInView = NO;
    gestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:gestureRecognizer];
    
    self.scrollView.minimumZoomScale = 1;
    self.scrollView.maximumZoomScale = 3.0;
    self.scrollView.contentSize = CGSizeMake(320, 480);
    self.scrollView.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close:(UIGestureRecognizer *)gestureRecognizer
{
    [self willMoveToParentViewController:nil];
    
    //Animation
    self.view.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.fullScreenImageView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)showFullImageInViewController:(UIViewController *)controller
                            withImage:(UIImage *)image
{
    self.view.frame = controller.view.frame;
    self.fullScreenImageView.image = image;
    self.fullScreenImageView.userInteractionEnabled = YES;
    
    [controller.view addSubview:self.view];
    [controller addChildViewController:self];
    [self didMoveToParentViewController:controller];
    
    //Animation
    // instantaneously make the image view small (scaled to 1% of its actual size)
    self.fullScreenImageView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        self.fullScreenImageView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
    }];
}

- (void)dealloc {
    NSLog(@"dealloc %@", self);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.fullScreenImageView;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
