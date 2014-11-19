//
//  PhishNetAuth.m
//  PhishOD
//
//  Created by Alec Gorge on 7/31/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PhishNetAuth.h"

#import <FXKeychain/FXKeychain.h>
#import <SVProgressHUD/SVProgressHUD.h>

#import "PhishNetAPI.h"
#import "PhishNetSignInViewController.h"

static NSString *kPhishNetUsernameKeychainKey = @"pnet_u";
static NSString *kPhishNetPasswordKeychainKey = @"pnet_p";
static NSString *kPhishNetAuthKeyKeychainKey = @"pnet_authkey";

@interface PhishNetAuth () <PhishNetSignInDelegate>

@property (nonatomic, copy) void (^signInBlock)(void);

@end

@implementation PhishNetAuth

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static PhishNetAuth *inst;
    dispatch_once(&once, ^ {
		inst = [self.alloc init];
	});
    return inst;
}

- (NSString *)username {
    return FXKeychain.defaultKeychain[kPhishNetUsernameKeychainKey];
}

- (NSString *)password {
    return FXKeychain.defaultKeychain[kPhishNetPasswordKeychainKey];
}

- (NSString *)authkey {
    return FXKeychain.defaultKeychain[kPhishNetAuthKeyKeychainKey];
}

- (BOOL)hasCredentials {
    return self.authkey && self.authkey.length > 0 &&
	       self.username && self.username.length > 0 &&
	       self.password && self.password.length > 0;
}

- (void)validateUsername:(NSString *)username
            withPassword:(NSString *)password
                    save:(BOOL)shouldSave
                  result:(void (^)(BOOL))result {
    [PhishNetAPI.sharedAPI authorizeUsername:username
								withPassword:password
									 success:^(BOOL validCredentials, NSString *token) {
										 result(validCredentials);
										 
										 if(shouldSave) {
											 FXKeychain.defaultKeychain[kPhishNetUsernameKeychainKey] = username;
											 FXKeychain.defaultKeychain[kPhishNetPasswordKeychainKey] = password;
											 FXKeychain.defaultKeychain[kPhishNetAuthKeyKeychainKey] = token;
										 }
									 }
									 failure:^(AFHTTPRequestOperation *operation, NSError *error) {
										 result(NO);
										 
										 UIAlertView *a = [UIAlertView.alloc initWithTitle:@"Phish.net Error"
																				   message:[error localizedDescription]
																				  delegate:nil
																		 cancelButtonTitle:@"OK"
																		 otherButtonTitles:nil];
										 [a show];
										 
										 dbug(@"error signing to phish.net: %@", error);
									 }];
}

- (void)ensureSignedInFrom:(UIViewController *)baseViewController
                   success:(void (^)(void))success {
    if(self.hasCredentials) {
        success();
        return;
    }
    
    self.signInBlock = success;
    
    PhishNetSignInViewController *vc = PhishNetSignInViewController.alloc.init;
    vc.delegate = self;
    
    UINavigationController *nav = [UINavigationController.alloc initWithRootViewController:vc];
    
    [baseViewController presentViewController:nav
                                     animated:YES
                                   completion:NULL];
}

- (void)signInViewController:(PhishNetSignInViewController *)vc
    tappedSignInWithUsername:(NSString *)username
                 andPassword:(NSString *)password {
    [SVProgressHUD showWithStatus:@"Contacting Phish.net"
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
                            UIAlertView *a = [UIAlertView.alloc initWithTitle:@"Phish.net Username or Password Incorrect"
                                                                      message:@"It would seem that your username or password is incorrect. You need to use the username and password you use on Phish.net."
                                                                     delegate:nil
                                                            cancelButtonTitle:@"OK"
                                                            otherButtonTitles:nil];
                            
                            [a show];
                        }
                    }];
}

- (void)dismissTappedInSignInViewController:(PhishNetSignInViewController *)vc {
    [vc.presentingViewController dismissViewControllerAnimated:YES
                                                    completion:NULL];
    
    self.signInBlock = nil;
}

- (void)signOut {
	FXKeychain.defaultKeychain[kPhishNetUsernameKeychainKey] = nil;
	FXKeychain.defaultKeychain[kPhishNetPasswordKeychainKey] = nil;
	FXKeychain.defaultKeychain[kPhishNetAuthKeyKeychainKey] = nil;
}

@end
