//
//  LivePhishAuth.m
//  PhishOD
//
//  Created by Alec Gorge on 7/24/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LivePhishAuth.h"

#import <FXKeychain/FXKeychain.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "LivePhishAPI.h"
#import "LivePhishSignInViewController.h"

static NSString *kPHLivePhishUsernameKeychainKey = @"lp_u";
static NSString *kPHLivePhishPasswordKeychainKey = @"lp_p";

@interface LivePhishAuth () <LivePhishSignInDelegate>

@property (nonatomic, copy) void (^signInBlock)(void);

@end

@implementation LivePhishAuth

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static LivePhishAuth *inst;
    dispatch_once(&once, ^ {
		inst = [self.alloc init];
	});
    return inst;
}

- (NSString *)username {
    return FXKeychain.defaultKeychain[kPHLivePhishUsernameKeychainKey];
}

- (NSString *)password {
    return FXKeychain.defaultKeychain[kPHLivePhishPasswordKeychainKey];
}

- (BOOL)hasCredentials {
    return self.username && self.username.length > 0 && self.password && self.password.length > 0;
}

- (void)validateUsername:(NSString *)username
            withPassword:(NSString *)password
                    save:(BOOL)shouldSave
                  result:(void (^)(BOOL))result {
    [LivePhishAPI.sharedInstance getUserTokenForUsername:username
                                            withPassword:password
                                                 success:^(BOOL validCredentials, NSString *token) {
                                                     result(validCredentials);
                                                     
                                                     if(shouldSave) {
                                                         FXKeychain.defaultKeychain[kPHLivePhishUsernameKeychainKey] = username;
                                                         FXKeychain.defaultKeychain[kPHLivePhishPasswordKeychainKey] = password;
                                                     }
                                                 }
                                                 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                                                     result(NO);

                                                     UIAlertView *a = [UIAlertView.alloc initWithTitle:@"LivePhish Error"
                                                                                               message:[error localizedDescription]
                                                                                              delegate:nil
                                                                                     cancelButtonTitle:@"OK"
                                                                                     otherButtonTitles:nil];
                                                     [a show];
                                                     
                                                     dbug(@"error signing to livephish: %@", error);
                                                 }];
}

- (void)ensureSignedInFrom:(UIViewController *)baseViewController
                   success:(void (^)(void))success {
    if(self.hasCredentials) {
        success();
        return;
    }
    
    self.signInBlock = success;
    
    LivePhishSignInViewController *vc = LivePhishSignInViewController.alloc.init;
    vc.delegate = self;
    
    UINavigationController *nav = [UINavigationController.alloc initWithRootViewController:vc];
    
    [baseViewController presentViewController:nav
                                     animated:YES
                                   completion:NULL];
}

- (void)signInViewController:(LivePhishSignInViewController *)vc
    tappedSignInWithUsername:(NSString *)username
                 andPassword:(NSString *)password {
    [SVProgressHUD showWithStatus:@"Contacting LivePhish"
                         maskType:SVProgressHUDMaskTypeBlack];
    
    [self validateUsername:username
              withPassword:password
                      save:YES
                    result:^(BOOL valid) {
                        [SVProgressHUD dismiss];
                        
                        if(valid) {
                            [vc.presentingViewController dismissViewControllerAnimated:YES
                                                                            completion:NULL];
                            
                            self.signInBlock();
                        }
                        else {
                            UIAlertView *a = [UIAlertView.alloc initWithTitle:@"LivePhish Email or Password Incorrect"
                                                                      message:@"It would seem that your email or password is incorrect. You need to use the email and password you use on LivePhish.com."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
                            
                            [a show];
                        }
                    }];
}

- (void)dismissTappedInSignInViewController:(LivePhishSignInViewController *)vc {
    [vc.presentingViewController dismissViewControllerAnimated:YES
                                                    completion:NULL];
    
    self.signInBlock = nil;
}

- (void)signOut {
	FXKeychain.defaultKeychain[kPHLivePhishUsernameKeychainKey] = nil;
	FXKeychain.defaultKeychain[kPHLivePhishPasswordKeychainKey] = nil;
}

@end
