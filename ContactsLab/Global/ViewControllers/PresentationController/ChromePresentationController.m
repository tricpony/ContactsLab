//
//  ChromePresentationController.m
//  ClinicalTrials
//
//  Created by aarthur on 5/24/17.
//  Copyright © 2017 Gigabit LLC. All rights reserved.
//

/**
 This code is based on a tutorial at:
 https://www.appcoda.com/presentation-controllers-tutorial/
 **/


#import "ChromePresentationController.h"

@interface ChromePresentationController() <UIAdaptivePresentationControllerDelegate>
@property (nonatomic, strong) UIView *chromeView;

@end

@implementation ChromePresentationController

- (instancetype)initWithPresentedViewController:(UIViewController*)presentedViewController presentingViewController:(UIViewController*)presentingViewController
{
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    
    self.chromeView = [[UIView alloc] init];
    self.chromeView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    self.chromeView.alpha = 0;
    [self.chromeView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(chromeTapped:)]];
    self.sizeFactorReduceTo = 0.75;
    
    return self;
}

- (void)chromeTapped:(id)sender
{
    UITapGestureRecognizer *gesture = (id)sender;
    
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (CGRect)frameOfPresentedViewInContainerView
{
    CGRect trimmedRect;
    CGFloat x,y,w,h;
    CGFloat aspectRatio;
    CGFloat sizeReduceTo = self.sizeFactorReduceTo;
    
    trimmedRect = self.containerView.bounds;
    aspectRatio = trimmedRect.size.height/trimmedRect.size.width;
    w = floorf(trimmedRect.size.width * sizeReduceTo);
    h = floorf(w * aspectRatio);
    x = (self.containerView.bounds.size.width - w)/2.0;
    y = (self.containerView.bounds.size.height - h)/2.0;
    trimmedRect = CGRectMake(x, y, w, h);

    return trimmedRect;
}

- (void)presentationTransitionWillBegin
{
    id<UIViewControllerTransitionCoordinator> coordinator = self.presentedViewController.transitionCoordinator;
    self.chromeView.frame = self.containerView.bounds;
    self.chromeView.alpha = 1.0;
    [self.containerView insertSubview:self.chromeView atIndex:0];
    
    if (coordinator) {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            self.chromeView.alpha = 1.0;
        } completion:NULL];
    }else{
        self.chromeView.alpha = 1.0;
    }
}

- (void)dismissalTransitionWillBegin
{
    id<UIViewControllerTransitionCoordinator> coordinator = self.presentedViewController.transitionCoordinator;

    if (coordinator) {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            self.chromeView.alpha = 0;
        } completion:NULL];
    }else{
        self.chromeView.alpha = 0;
    }

}

- (BOOL)shouldPresentInFullscreen
{
    return YES;
}

- (void)containerViewWillLayoutSubviews
{
    self.chromeView.frame = self.containerView.bounds;
    self.presentedView.frame = [self frameOfPresentedViewInContainerView];
}

#pragma mark UISplitViewControllerDelegate

- (BOOL)splitViewController:(UISplitViewController *)splitViewController collapseSecondaryViewController:(UIViewController *)secondaryViewController
  ontoPrimaryViewController:(UIViewController *)primaryViewController
{
    [self.presentingViewController dismissViewControllerAnimated:YES completion:NULL];
    return NO;
}

@end

@interface ChromeAnimatedTransitioning : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) BOOL isPresenting;

@end

@implementation ChromeAnimatedTransitioning

#pragma mark UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.2;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    CGRect animateFromFrame;        //this is where the animated transition starts
    CGRect animateToFrame;          //this is where the animated transition ends
    UIViewController *fromVC;
    UIViewController *toVC;
    UIView *fromView;
    UIView *toView;
    UIView *containerView = transitionContext.containerView;
    CGRect contextInitialFrame = [transitionContext initialFrameForViewController:toVC];
    CGPoint center;
    
    fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    fromView = fromVC.view;
    toView = toVC.view;

    if (self.isPresenting) {
        
        [containerView addSubview:toView];
        
        //move center offscreen centered above the screen frame
        toView.center = CGPointMake(CGRectGetMidX(containerView.bounds),CGRectGetMidY(containerView.bounds));
        animateToFrame = toView.frame;
        center = toView.center;
        center.y -= fromVC.view.frame.size.height/2.0;
        toView.center = CGPointMake(center.x, center.y);
        animateFromFrame = toView.frame;

    }else{
        animateFromFrame = contextInitialFrame;
        
        //this block is invoked by animationControllerForDismissedController
        //this block never executes
        //see comments on animationControllerForDismissedController below
        animateToFrame = toView.frame;
        center = toView.center;
        center.y += fromVC.view.frame.size.height/2.0;
        toView.center = center;
        animateToFrame = toView.frame;

    }
    
    toView.frame = animateFromFrame;
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        toView.frame = animateToFrame;
    } completion:^(BOOL finished) {
        if (!self.isPresenting) {
            [toView removeFromSuperview];
        }
        [transitionContext completeTransition:YES];
    }];
}

@end

@implementation ChromeTransitioningDelegate

#pragma mark UIViewControllerTransitioningDelegate

- (UIPresentationController*)presentationControllerForPresentedViewController:(UIViewController*)presented
                                                      presentingViewController:(UIViewController*)presenting
                                                          sourceViewController:(UIViewController*)source
{
    ChromePresentationController *presentationController;
    
    presentationController = [[ChromePresentationController alloc] initWithPresentedViewController:presented presentingViewController:source];
    return presentationController;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController*)presented
                                                                  presentingController:(UIViewController*)presenting
                                                                      sourceController:(UIViewController*)source
{
    ChromeAnimatedTransitioning *transitioner = [[ChromeAnimatedTransitioning alloc] init];
    
    transitioner.isPresenting = YES;
    return transitioner;
}

/**
 Taking this out allows default behavior which looks fine so I am not bothering with it
 **/
//- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController*)dismissed
//{
//    ChromeAnimatedTransitioning *transitioner = [[ChromeAnimatedTransitioning alloc] init];
//    
//    transitioner.isPresenting = NO;
//    return transitioner;
//}

@end
