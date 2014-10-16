//
//  IGThirdPartyKeys.h
//  iguana
//
//  Created by Alec Gorge on 3/29/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IGThirdPartyKeys : NSObject

+ (instancetype)sharedInstance;

@property (readonly) BOOL isAmazonInsightsEnabled;
@property (readonly) NSString *amazonInsightsPublicKey;
@property (readonly) NSString *amazonInsightsPrivateKey;

@property (readonly) BOOL isLastFmEnabled;
@property (readonly) NSString *lastFmApiKey;
@property (readonly) NSString *lastFmApiSecret;

@property (readonly) BOOL isPhishNetEnabled;
@property (readonly) NSString *phishNetApiKey;
@property (readonly) NSString *phishNetPubKey;

@property (readonly) BOOL isCrashlyticsEnabled;
@property (readonly) NSString *crashlyticsApiKey;

//@property (readonly) BOOL isPhishtracksStatsEnabled;
@property (readonly) NSString *phishtracksStatsApiKey;

@end
