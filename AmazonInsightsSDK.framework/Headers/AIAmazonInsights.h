/*
 * Copyright 2013 Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#import <Foundation/Foundation.h>
#import "AIInsightsCredentials.h"
#import "AIInsightsOptions.h"
#import "AIABTestClient.h"
#import "AIEventClient.h"
#import "AIUserProfile.h"

@class AIAmazonInsights;
typedef void(^AIInitializationCompletionBlock)(AIAmazonInsights *);


/**
 * <p>
 * AIAmazonInsights is the entry point of the SDK. For step by step instructions on how to integrate this SDK
 * with your A/B tests, visit the <a href="https://developer.amazon.com/sdk/ab-testing/documentation/ios-setup.html">Integrate the SDK</a>
 * page of the Amazon Insights documentation.
 * </p>
 *
 * <p>
 * For step by step instructions on how to integrate this SDK
 * with your Analytics Reports, visit the <a href="https://developer.amazon.com/sdk/analytics/documentation/ios-setup.html">Integrate the SDK</a>
 * page of the Amazon Insights documentation.
 * </p>
 *
 * <p>
 * To create an AIAmazonInsights instance for A/B Testing and/or Analytics, first create a new {@link AIInsightsCredentials} object by invoking
 * the AIAmazonInsights::credentialsWithApplicationKey:withPrivateKey: method. When creating your credentials, use the Public and Private
 * keys of the Identifier you setup in the <a href="https://developer.amazon.com/home.html">Amazon Developer Portal</a>. See the
 * <a href="https://developer.amazon.com/sdk/analytics/documentation/ios-setup.html">Amazon Insights Documentation</a> for more information on how to create and use
 * Identifiers.
 * </p>
 *
 * <p>
 * You create an AIAmazonInsights instance by calling AIAmazonInsights::insightsWithCredentials: with your credentials provided.
 * </p>
 *
 * <h3>Example:</h3>
 * @code
 * // Using the Identifier you created in the Amazon Developer Portal site, create a credentials object with the Identifier's Public and Private Keys.
 * // The Identifier's Public Key acts as the application key.
 * id<AIInsightsCredentials> credentials = [AIAmazonInsights credentialsWithApplicationKey:@"YOUR_APP_KEY"
 *                                                                          withPrivateKey:@"YOUR_PRIVATE_KEY"];
 *
 * //initialize a new instance of AmazonInsights
 * AIAmazonInsights* insights = [AIAmazonInsights insightsWithCredentials: credentials];
 * @endcode
 *
 * <p>
 * You can also customize an AIAmazonInsights instance by calling the AIAmazonInsights::insightsWithCredentials:withOptions: method
 * with an AIInsightsOptions object. Initializing the SDK this way allows you to enable/disable event collection and
 * enable/disable WAN delivery of events.
 * </p>
 *
 * <h3>Example:</h3>
 * @code
 * //Create an options object to allow event collection and allow WAN delivery
 * id<AIInsightsOptions> options = [AIAmazonInsights optionsWithAllowEventCollection:YES 
 *                                                              withAllowWANDelivery:YES];
 *
 * // Using the Identifier you created in the Amazon Developer Portal site, create a credentials object with the Identifier's Public and Private Keys
 * // The Identifier's Public Key acts as the application key.
 * id<AIInsightsCredentials> credentials = [AIAmazonInsights credentialsWithApplicationKey:@"YOUR_APP_KEY"
 *                                                                          withPrivateKey:@"YOUR_PRIVATE_KEY"];
 *
 * //initialize a new instance of AIAmazonInsights
 * AIAmazonInsights* insights = [AIAmazonInsights insightsWithCredentials: credentials withOptions: options];
 * @endcode
 *
 * <p>
 * After you create an AIAmazonInsights instance, you can either maintain the reference to the AIAmazonInsights instance yourself
 * or access it later by using the AIAmazonInsights::insightsWithCredentials: providing the credentials to retrieve the cached instance.
 * </p>
 *
 * <p>
 * Once you create an instance, you can:
 * <ul>
 *   <li> access the AIABTestClient to retrieve AIVariations</li>
 *   <li> access the AIEventClient to create, record, and submit events</li>
 *   <li> access the AIUserProfile to update dimensions used for Segmentation </li>
 *   <li> access the AIAppleMonetizationEventBuilder or AIVirtualMonetizationEventBuilder to record monetization purchase events</li>
 * </ul>
 * </p>
 */
@interface AIAmazonInsights : NSObject

/**
 * Return the AIABTestClient
 * @returns the AIABTestClient to retrieve AIVariations
 */
@property (nonatomic, readonly) id<AIABTestClient> abTestClient;

/**
 * Return the AIEventClient
 * @returns the AIEventClient to create, record, and submit events
 */
@property (nonatomic, readonly) id<AIEventClient> eventClient;

/**
 * Return the AIUserProfile of the User
 * @returns the AIUserProfile of the User
 */
@property (nonatomic, readonly) id<AIUserProfile> userProfile;

/**
 * Create a new AIInsightsCredentials instance
 * @param theApplicationKey The Public key of the Identifier you created in the Amazon Developer Portal. Currently
                            the Public Key of an Amazon Insights Identifier also acts as the Application key.
 * @param thePrivateKey The The Private key of the Identifier you created in the Amazon Developer Portal
 * @returns a new AIInsightsCredential instance with the specified application and private key
 */
+(id<AIInsightsCredentials>) credentialsWithApplicationKey:(NSString *) theApplicationKey
                                            withPrivateKey:(NSString *) thePrivateKey;

/**
 * Create an AIInsightsOptions object set to the Insights SDK defaults.
 * @returns An AIInsightsOptions object where: AIInsightsOptions::allowEventCollection is true
 *                                             AIInsightsOptions::allowWANDelivery is false
 */
+(id<AIInsightsOptions>) defaultOptions;

/**
 * Create a new AIInsightsOptions object with the specified values
 * @param allowEventCollection enable/disable event collection for the entire SDK
 * @param allowWANDelivery <ul>
 *                             <li>YES - allows events to be submitted when the user has either a WAN or WIFI connection to the internet</li>
 *                             <li>NO - events are only submitted when the user has a WIFI connection to the internet</li>
 *                         </ul>
 * @returns a new AIInsightsOptions object with the specified values
 */
+(id<AIInsightsOptions>) optionsWithAllowEventCollection:(BOOL)allowEventCollection
                                    withAllowWANDelivery:(BOOL)allowWANDelivery;

/**
 * Create an AIAmazonInsights object using the default AIInsightsOptions values
 * @param theCredentials The credentials created from the Amazon Insights Identifier
 * @returns an AIAmazonInsights instance
 */
+(AIAmazonInsights *) insightsWithCredentials:(id<AIInsightsCredentials>) theCredentials;

/**
 * Create an AIAmazonInsights object using the specified AIInsightsOptions values
 * @param theCredentials The credentials created from the Amazon Insights Identifier
 * @param theOptions The AIInsightsOptions to use when creating the AIAmazonInsights instance
 * @returns an AIAmazonInsights instance
 */
+(AIAmazonInsights *) insightsWithCredentials:(id<AIInsightsCredentials>) theCredentials
                                 withOptions:(id<AIInsightsOptions>) theOptions;

/**
 * Create an AIAmazonInsights object using the default AIInsightsOptions values
 * @param theCredentials The credentials created from the Amazon Insights Identifier
 * @param theOptions The AIInsightsOptions to use when creating the AIAmazonInsights instance
 * @param completionBlock A AIInitializationCompletionBlock that allows developers to handle custom logic after initialization but before the session begins
 * @returns an AIAmazonInsights instance
 */
+(AIAmazonInsights *) insightsWithCredentials:(id<AIInsightsCredentials>) theCredentials
                                  withOptions:(id<AIInsightsOptions>) theOptions
                          withCompletionBlock:(AIInitializationCompletionBlock)completionBlock;


@end
