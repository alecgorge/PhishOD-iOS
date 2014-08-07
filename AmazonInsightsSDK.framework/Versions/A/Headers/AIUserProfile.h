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

/**
 * AIUserProfile is used to define dimensions (or characteristics) about the current user.
 * These dimensions are used when allocating AIVariations so that only a specific segment of users participate in the experiment.
 * Users not in the experiment segment receive the Control variation, but their actions do not influence any A/B view or conversions.
 *
 * <h3>Example</h3>
 * The example below demonstrates how to define dimensions about the current user. These dimensions are completely developer
 * driven and can be any values you wish to "tag" about a user. It is up to you to determine how these dimensions are obtained.
 *
 * @code
 * // Using the Identifier you created in the Amazon Developer Portal site, create a credentials object with the Identifier's Public and Private Keys.
 * // The Identifier's Public Key acts as the application key.
 * id<AIInsightsCredentials> credentials = [AIAmazonInsights credentialsWithApplicationKey:@"YOUR_APP_KEY"
 *                                                                          withPrivateKey:@"YOUR_PRIVATE_KEY"];
 *
 * //initialize a new instance of AmazonInsights specifically for your application.
 * AIAmazonInsights* insights = [AIAmazonInsights insightsWithCredentials: credentials];
 *
 * // get information from external source (i.e. preferences dialog)
 * NSNumber* userId = ...;
 *
 * // set dimensions via AIUserProfile API
 * id<AIUserProfile> userProfile = insights.userProfile;
 * [userProfile addDimensionAsNumber:userId 
 *                           forName:@"user_id"];
 * @endcode
 *
 *
 * <p>You can set AIUserProfile dimensions from multiple threads; however, the synchronization of elements is not guaranteed.
 * For example, when the SDK is allocating AIVariations in thread 1, there might be 3 user dimensions defined.
 * At the same time in thread 2, you add another dimension. The SDK cannot guarantee that the 4th dimension
 * will be used when allocating variations in thread 1. To ensure that the correct dimensions are used, it is recommended
 * that you set all user dimensions before allocating AIVariations.</p>
 *
 * <p>Once a user has been allocated an AIVariation for a particular segment, the user will maintain the AIVariation even if the dimensions change.
 * For example, if yesterday a user received an AIVariation that was targeted for debug accounts, and today they are no longer a debug account, the user will
 * maintain the AIVariation they received (even though they are no longer in the segment). Once a new experiment has been started, the current dimensions
 * will be used to determine a brand new AIVariation.</p>
 */
@protocol AIUserProfile <NSObject>

/**
 * Get the current dimensions of this AIUserProfile
 * @returns an NSDictionary of the dimensions
 */
@property (nonatomic, readonly) NSDictionary *dimensions;

/**
 * Add an NSNumber* dimension to this AIUserProfile.
 * @param theValue The NSNumber* value of the dimension.
 * @param theName The name of the dimension
 * @returns returns the AIUserProfile object to allow for method chaining
 */
@required
-(id<AIUserProfile>) addDimensionAsNumber:(NSNumber *)theValue forName:(NSString *)theName;

/**
 * Add an NSString* dimension to this AIUserProfile.
 * @param theValue The NSString* value of the dimension.
 * @param theName The name of the dimension
 * @returns returns the AIUserProfile object to allow for method chaining
 */
@required
-(id<AIUserProfile>) addDimensionAsString:(NSString *)theValue forName:(NSString *)theName;

@end
