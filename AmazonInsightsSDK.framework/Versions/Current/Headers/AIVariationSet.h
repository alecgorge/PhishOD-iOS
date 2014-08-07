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
#import "AIVariation.h"

/**
 * A collection of AIVariation objects that have been allocated for the current user.
 *
 * The example below demonstrates how to allocate a set of AIVariations.
 * An AIVariation can then be obtained from the AIVariationSet object.
 *
 * @code
 * // get the AB Client to request variations
 * id<AIABTestClient> abTestClient = insights.abTestClient;
 *
 * [abTestClient variationsByProjectNames:[NSArray arrayWithObject:@"Level1Revenue"]
 *   withCompletionHandler:^(id<AIVariationSet> variationSet, NSError* error) {
 *       if(error == nil) {
 *           // request an AIVariation out of the AIVariationSet
 *           id<AIVariation> revenueVariation = [variationSet variationForProjectName:@"Level1Revenue"];
 *       }
 *   }];
 * @endcode
 */
@protocol AIVariationSet <NSObject, NSFastEnumeration>

/**
 * Return the AIVariation allocated for this user for the specified project name.
 * @param projectName The name of the project to obtain a variation for.
 * @returns The AIVariation object allocated for the current user.
 */
@required
- (id<AIVariation>)variationForProjectName:(NSString *)projectName;

/**
 * Returns a BOOL indicating whether or not an AIVariation exists in the set for the specified project name.
 * @param projectName The name of the project to search for.
 * @returns A BOOL indicating whether or not the AIVariation exists in the set.
 */
@required
- (BOOL)containsVariation:(NSString *)projectName;

/**
 * Returns an NSUInteger indicating the number of AIVariations in the set.
 * @returns An NSUInteger indicating the number of AIVariations in the set.
 */
@required
- (NSUInteger)count;

@end
