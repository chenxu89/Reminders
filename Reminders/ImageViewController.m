//
//  ImageViewController.m
//  Reminders
//
//  Created by 陈旭 on 6/15/15.
//  Copyright (c) 2015 陈旭. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController () <UIGestureRecognizerDelegate, UIScrollViewAccessibilityDelegate, UIScrollViewDelegate>
{
    CGFloat currentScale;//当前倍率
    CGFloat minScale;//最小倍率
    CGFloat maxScale;
}

@end

@implementation ImageViewController

- (id)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.scrollView.backgroundColor = [UIColor blackColor];
    
    //最大放大倍数(默认值)
    maxScale=2.0;
    //设置最小倍率为1.0
    minScale=1.0;
    //设置当前的放大倍数
    currentScale=1.0;
    
    //控制器
    self.scrollView.userInteractionEnabled = YES;
    self.scrollView.minimumZoomScale = 1.0;//最小倍率（默认倍率）
    self.scrollView.maximumZoomScale = 2.0;//最大倍率（默认倍率）
    self.scrollView.decelerationRate = 1.0;//减速倍率（默认倍率）
    self.scrollView.delegate = self;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight;
    
    //图片
    
    self.imageView.userInteractionEnabled=YES;
    self.imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleHeight;
    
    
    // what object is going to handle the gesture when it gets recognised ?
    // the argument for tap is the gesture that caused this message to be sent
    UITapGestureRecognizer *tapOnce = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(close:)];
    UITapGestureRecognizer *tapTwice=[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleGesture:)];
    
    // set number of taps required
    tapOnce.numberOfTapsRequired = 1;
    tapTwice.numberOfTapsRequired = 2;
    
    // now add the gesture recogniser to a view
    // this will be the view that recognises the gesture
    [self.imageView addGestureRecognizer:tapOnce];
    [self.imageView addGestureRecognizer:tapTwice];
    
    //other
    [self.scrollView setContentSize:CGSizeMake(self.imageView.bounds.size.width * 2.0, self.imageView.bounds.size.height *2.0)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)close:(UIGestureRecognizer *)gestureRecognizer
{
    [self willMoveToParentViewController:nil];
    
    //Animation
    self.scrollView.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.imageView.transform = CGAffineTransformMakeScale(0.01, 0.01);
    } completion:^(BOOL finished){
        // if you want to do something once the animation finishes, put it here
        [self.scrollView removeFromSuperview];
        [self removeFromParentViewController];
    }];
}

- (void)showFullImageInViewController:(UIViewController *)controller
                            withImage:(UIImage *)image
{
    self.scrollView.frame = controller.view.frame;
    self.imageView.image = image;
    self.imageView.userInteractionEnabled = YES;
    
    [controller.view addSubview:self.scrollView];
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


#pragma mark -UIScrollView delegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

-(void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(double)scale
{
    currentScale=scale;
}

#pragma mark -DoubleGesture Action
-(void)doubleGesture:(UIGestureRecognizer *)sender
{
    
    //当前倍数等于最大放大倍数
    //双击默认为缩小到原图
    if (currentScale==maxScale) {
        currentScale=minScale;
        [self.scrollView setZoomScale:currentScale animated:YES];
        return;
    }
    //当前等于最小放大倍数
    //双击默认为放大到最大倍数
    if (currentScale==minScale) {
        currentScale=maxScale;
        [self.scrollView setZoomScale:currentScale animated:YES];
        return;
    }
    
    CGFloat aveScale =minScale+(maxScale-minScale)/2.0;//中间倍数
    
    //当前倍数大于平均倍数
    //双击默认为放大最大倍数
    if (currentScale>=aveScale) {
        currentScale=maxScale;
        [self.scrollView setZoomScale:currentScale animated:YES];
        return;
    }
    
    //当前倍数小于平均倍数
    //双击默认为缩小到原图
    if (currentScale<aveScale) {
        currentScale=minScale;
        [self.scrollView setZoomScale:currentScale animated:YES];
        return;
    }
}


@end
