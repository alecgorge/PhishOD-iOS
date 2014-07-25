//
//  LivePhishSignInViewController.h
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LivePhishSignInViewController;

@protocol LivePhishSignInDelegate <NSObject>

- (void)signInViewController:(LivePhishSignInViewController *)vc
    tappedSignInWithUsername:(NSString *)username
                 andPassword:(NSString *)password;

- (void)dismissTappedInSignInViewController:(LivePhishSignInViewController *)vc;

@end

@interface LivePhishSignInViewController : UITableViewController

@property (nonatomic, weak) id<LivePhishSignInDelegate> delegate;

@end
