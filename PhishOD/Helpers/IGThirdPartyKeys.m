//
//  IGThirdPartyKeys.m
//  iguana
//
//  Created by Alec Gorge on 3/29/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "IGThirdPartyKeys.h"

@interface IGThirdPartyKeys ()

@property (nonatomic, strong) NSDictionary *config;
@property (nonatomic, strong) NSString *activeConfig;

@end

@implementation IGThirdPartyKeys

+ (instancetype)sharedInstance {
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    if (self = [super init]) {
        self.config = [NSDictionary.alloc initWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"API keys"
                                                                                               ofType:@"plist"]];
        
        self.activeConfig = NSBundle.mainBundle.infoDictionary[@"BUILD_CONFIGURATION"];
    }
    return self;
}

- (BOOL)boolForKeypath:(NSString *)keypath {
    id res = [self.config[self.activeConfig] valueForKeyPath:keypath];
    
    if(!res) {
        res = [self.config[@"All"] valueForKeyPath:keypath];
    }
    
    return res ? [res boolValue] : NO;
}

- (NSString *)stringForKeypath:(NSString *)keypath {
    id res = [self.config[self.activeConfig] valueForKeyPath:keypath];
    
    if(!res) {
        res = [self.config[@"All"] valueForKeyPath:keypath];
    }
    
    return res ? res : @"";
}

- (BOOL)isAmazonInsightsEnabled {
    return [self boolForKeypath:@"amazon_insights_enabled"];
}

- (NSString *)amazonInsightsPublicKey {
    return [self stringForKeypath:@"amazon_insights_key_public"];
}

- (NSString *)amazonInsightsPrivateKey {
    return [self stringForKeypath:@"amazon_insights_key_private"];
}

- (BOOL)isLastFmEnabled {
    return [self boolForKeypath:@"lastfm_enabled"];
}

- (NSString *)lastFmApiKey {
    return [self stringForKeypath:@"lastfm_key"];
}

- (NSString *)lastFmApiSecret {
    return [self stringForKeypath:@"lastfm_secret"];
}

- (BOOL)isPhishNetEnabled {
    return [self boolForKeypath:@"phishnet_enabled"];
}

- (NSString *)phishNetApiKey {
    return [self stringForKeypath:@"phishnet_apikey"];
}

- (NSString *)phishNetPubKey {
    return [self stringForKeypath:@"phishnet_pubkey"];
}

- (BOOL)isCrashlyticsEnabled {
    return [self boolForKeypath:@"crashlytics_enabled"];
}

- (NSString *)crashlyticsApiKey {
    return [self stringForKeypath:@"crashlytics_key"];
}

@end
