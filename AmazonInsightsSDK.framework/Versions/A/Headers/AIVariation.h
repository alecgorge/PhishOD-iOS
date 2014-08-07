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
 * <p>AIVariation represents a variation that was allocated for a project.
 * When a developer makes a request to allocate variation(s), a request is made to the server.
 * The server determines which variation(s) to allocate (based on the application key, project name, and the current user).
 * </p>
 *
 * <p>If the requested project is an A/B test, the user will continue to receive the same variation
 * they were allocated until the A/B test has ended despite changes to the distribution.
 * </p>
 *
 * <p>If the requested project is a launch, the user will receive the variation that corresponds to the current
 * distribution percentage. This means a user could transition between variations when the distribution percentages
 * are changed.
 * </p>
 *
 * <p>When an AIVariation is returned, developers can retrieve variables from the variation by utilizing one of the variableAsXXX:withDefault: selectors.</p>
 *
 * Example:
 * @code
 * // get the AB Client to request variations
 * id<AIABTestClient> abTestClient = insights.abTestClient;
 *
 * [abTestClient variationsByProjectNames:[NSArray arrayWithObject:@"Level1Revenue"]
 *   withCompletionHandler:^(id<AIVariationSet> variationSet, NSError* error) {
 *       if(error == nil) {
 *           // request an AIVariation out of the AIVariationSet
 *           id<AIVariation> revenueVariation = [variationSet variationForProjectName:@"Level1Revenue"];
 *           NSString* buyMessage = [revenueVariation variableAsString:@"buyMessage" 
 *                                                         withDefault:@"Upgrade?"];
 *       }
 *   }];
 * @endcode
 *
 * <p>
 * Occasionally, the SDK may not be able to retrieve an AIVariation from the server due to connectivity. When this occurs, there will not be any variables within the instance.
 * Since developers must use one of the variableAsXXX:withDefault: selectors, all queries to the AIVariation object for variable values will return the default value. So in the
 * examples provided above, the <code>buyMessage</code> variable would be assigned the value of <em>\@"Upgrade?"</em>.
 * </p>
 */
@protocol AIVariation <NSObject>

/**
 * Return the name of the project this variation was allocated for.
 * @returns The name of the project.
 */
@required
@property (nonatomic, readonly) NSString* projectName;

/**
 * Returns the name of the variation allocated for this user.
 * @returns The name of the variation received for this user.
 *     <p>DEFAULT  - The user has not been allocated a variation<p/>
 *     <p>CONTROL  - The user has been allocated into the Control (Variation A) variation<p/>
 *     <p>TEST(N) - The user has been allocated into the Test (Variation B-N) variation. N will start at 2 and go through to N<p/>
 */
@required
@property (nonatomic, readonly) NSString* name;

/**
 * Return the variable with the <code>variableName</code> key as an <code>int</code>.
 * @param variableName the name of the variable to return.
 * @param defaultValue the value this variable should have if it doesn't exist or
 * the user has not been allocated a variation.
 * @returns the variable expressed as an <code>int</code>.
 */
@required
- (int)variableAsInt:(NSString *)variableName withDefault:(int)defaultValue;

/**
 * Return the variable with the <code>variableName</code> key as a <code>long long</code>.
 * @param variableName the name of the variable to return.
 * @param defaultValue the value this variable should have if it doesn't exist or
 * the user has not been allocated a variation.
 * @returns the variable expressed as a <code>long long</code>.
 */
@required
- (long long)variableAsLongLong:(NSString *)variableName withDefault:(long long)defaultValue;

/**
 * Return the variable with the <code>variableName</code> key as a <code>float</code>.
 * @param variableName the name of the variable to return.
 * @param defaultValue the value this variable should have if it doesn't exist or
 * the user has not been allocated a variation.
 * @returns the variable expressed as a <code>float</code>.
 */
@required
- (float)variableAsFloat:(NSString *)variableName withDefault:(float)defaultValue;

/**
 * Return the variable with the <code>variableName</code> key as a <code>double</code>.
 * @param variableName the name of the variable to return.
 * @param defaultValue the value this variable should have if it doesn't exist or
 * the user has not been allocated a variation.
 * @returns the variable expressed as a <code>double</code>.
 */
@required
- (double)variableAsDouble:(NSString *)variableName withDefault:(double)defaultValue;

/**
 * Return the variable with the <code>variableName</code> key as a <code>BOOL</code>.
 * @param variableName the name of the variable to return.
 * @param defaultValue the value this variable should have if it doesn't exist or
 * the user has not been allocated a variation.
 * @returns the variable expressed as a <code>BOOL</code>.
 */
@required
- (BOOL)variableAsBool:(NSString *)variableName withDefault:(BOOL)defaultValue;

/**
 * Return the variable with the <code>variableName</code> key as a <code>NSString*</code>.
 * @param variableName the name of the variable to return.
 * @param defaultValue the value this variable should have if it doesn't exist or
 * the user has not been allocated a variation.
 * @returns the variable expressed as a <code>NSString*</code>.
 */
@required
- (NSString *)variableAsString:(NSString *)variableName withDefault:(NSString *)defaultValue;

/**
 * Determine if the variable specified by variable name exists in this variation.
 * @param variableName the name of the variable to search for.
 * @returns <code>YES</code> if the variable exists, <code>NO</code> otherwise.
 */
@required
- (BOOL)containsVariable:(NSString *)variableName;

@end
