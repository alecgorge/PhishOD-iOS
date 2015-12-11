//
//  RLPushPopAnimator.m
//  PhishOD
//
//  Created by George Lo on 12/10/15.
//  Copyright © 2015 Alec Gorge. All rights reserved.
//

#import "RLPushPopAnimator.h"

@implementation RLPushPopAnimator

@synthesize dismissing;
@synthesize percentageDriven;

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.75;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIView *topView = dismissing ? fromViewController.view : toViewController.view;
    UIViewController *bottomViewController = dismissing ? toViewController : fromViewController;
    UIView *bottomView = bottomViewController.view;
    CGFloat offset = bottomView.bounds.size.width;
    if ([bottomViewController isKindOfClass:[UINavigationController class]]) {
        bottomView = ((UINavigationController*)bottomViewController).topViewController.view;
    }
    
    [[transitionContext containerView] insertSubview:toViewController.view aboveSubview:fromViewController.view];
    if (dismissing) {
        [[transitionContext containerView] insertSubview:toViewController.view belowSubview:fromViewController.view];
    }
    
    topView.frame = fromViewController.view.frame;
    topView.transform = dismissing ? CGAffineTransformIdentity : CGAffineTransformMakeTranslation(offset, 0);
    
    UIImageView *shadowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shadow"]];
    shadowView.contentMode = UIViewContentModeScaleAspectFill;
    shadowView.layer.anchorPoint = CGPointMake(0, 0.5);
    shadowView.frame = bottomView.bounds;
    [bottomView addSubview:shadowView];
    shadowView.transform = dismissing ? CGAffineTransformMakeScale(0.01, 1) : CGAffineTransformIdentity;
    shadowView.alpha = self.dismissing ? 1.0 : 0.0;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext]
                          delay:0
         usingSpringWithDamping:0.9
          initialSpringVelocity:1.0
                        options:[self animOpts]
                     animations:^{
        topView.transform = self.dismissing ? CGAffineTransformMakeTranslation(offset, 0) : CGAffineTransformIdentity;
        shadowView.transform = self.dismissing ? CGAffineTransformIdentity : CGAffineTransformMakeScale(0.01, 1);
        shadowView.alpha = self.dismissing ? 0.0 : 1.0;
    } completion:^(BOOL finished) {
        topView.transform = CGAffineTransformIdentity;
        [shadowView removeFromSuperview];
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (UIViewAnimationOptions)animOpts {
    return UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionLayoutSubviews;
}

@end
