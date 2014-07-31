//
//  PhishNetSignInViewController.h
//  PhishOD
//
//  Created by Alec Gorge on 7/31/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

@class PhishNetSignInViewController;

@protocol PhishNetSignInDelegate <NSObject>

- (void)signInViewController:(PhishNetSignInViewController *)vc
    tappedSignInWithUsername:(NSString *)username
                 andPassword:(NSString *)password;

- (void)dismissTappedInSignInViewController:(PhishNetSignInViewController *)vc;

@end

@interface PhishNetSignInViewController : UITableViewController

@property (nonatomic, weak) id<PhishNetSignInDelegate> delegate;

@end

