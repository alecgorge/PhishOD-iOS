//
//  RLPushPopAnimator.h
//  PhishOD
//
//  Created by George Lo on 12/10/15.
//  Copyright © 2015 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RLPushPopAnimator : UIPercentDrivenInteractiveTransition <UIViewControllerAnimatedTransitioning>

@property (nonatomic) BOOL dismissing;
@property (nonatomic) BOOL percentageDriven;

@end
