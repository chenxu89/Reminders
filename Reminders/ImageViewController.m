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
    
    //singleTap to close
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
    singleTap.cancelsTouchesInView = NO;
    singleTap.delegate = self;
    [self.view addGestureRecognizer:singleTap];
    
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 2.5;
    self.scrollView.delegate = self;
    
    //设置滚动不显示
    self.scrollView.showsHorizontalScrollIndicator=NO;
    self.scrollView.showsVerticalScrollIndicator=NO;
    
    //doubleTap to zoom
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.scrollView addGestureRecognizer:doubleTap];
    
    //防止单击干扰双击
    [singleTap requireGestureRecognizerToFail:doubleTap];
}

- (void)handleDoubleTap:(UIGestureRecognizer *)recognizer
{

    
    if(self.scrollView.zoomScale > self.scrollView.minimumZoomScale){
       [self.scrollView setZoomScale:self.scrollView.minimumZoomScale animated:YES];
    }
    else{
        //点击任何位置都从中心缩放
        [self.scrollView setZoomScale:self.scrollView.maximumZoomScale animated:YES];
        
//        //以双击点为中心缩放
//        CGPoint pointInView = [recognizer locationInView:self.imageView];
//        CGRect zoomRect = [self zoomRectForScale:self.scrollView.maximumZoomScale withCenter:pointInView];
//        [self.scrollView zoomToRect:zoomRect animated:YES];
    }
}

////以双击点为中心缩放
//- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center
//{
//    // the zoom rect is in the content view's coordinates.
//    CGRect zoomRect;
//    zoomRect.size.height = self.scrollView.frame.size.height / scale;
//    zoomRect.size.width  = self.scrollView.frame.size.width  / scale;
//    
//    zoomRect.origin.x = center.x - (zoomRect.size.width  /2.0);
//    zoomRect.origin.y = center.y - (zoomRect.size.height /2.0);
//
//    return zoomRect;
//}

- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self willMoveToParentViewController:nil];
    
    //show navigation bar and status bar
    [[UIApplication sharedApplication] setStatusBarHidden: NO withAnimation: UIStatusBarAnimationFade];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    //Animation
    self.view.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.imageView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)showFullImageInViewController:(UIViewController *)controller
                            withImage:(UIImage *)image
{
    //hide navigation bar and status bar
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    [controller.navigationController setNavigationBarHidden:YES animated:NO];
    
    self.view.frame = controller.view.frame;
    self.imageView.image = image;
    self.imageView.userInteractionEnabled = YES;
    
    [controller.view addSubview:self.view];
    [controller addChildViewController:self];
    [self didMoveToParentViewController:controller];
    
    //Animation
    // instantaneously make the image view small (scaled to 1% of its actual size)
    self.imageView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        // animate it to the identity transform (100% scale)
        self.imageView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
    }];
}

- (void)dealloc {
    NSLog(@"dealloc %@", self);
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
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
