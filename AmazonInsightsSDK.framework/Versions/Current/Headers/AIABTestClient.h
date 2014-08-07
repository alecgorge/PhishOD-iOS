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
#import "AIVariationSet.h"

FOUNDATION_EXPORT NSString * const AIABTestClientErrorDomain;

typedef NS_ENUM(NSInteger, AIABTestClientErrorCodes) {
    AIABTestClientErrorCode_NoProjectNamesProvided = 0,
    AIABTestClientErrorCode_ProjectNamesNil
};

/**
 * A typedef for the block required to be provided to the AIABTestClient::variationsByProjectNames:withCompletionHandler: to recieve the
 * AIVariationSet served
 * @param The AIVariationSet retrieved for the request.
 * @param The NSError object if there was a failure in retrieving the AIVariations. This should be nil if no errors occurred.
 */
typedef void (^ AICompletionHandler)(id<AIVariationSet>, NSError*);

/**
 * AIABTestClient is the entry point into the Amazon Insights SDK where variations are retrieved for projects.
 *
 * <h3>Allocation Example</h3>
 * The example below demonstrates how to allocate a variation for a specific project.
 * Once an AIVariation is received, the developer obtains the variables from the AIVariation to vary the behavior. In this
 * example, the developer is requesting a variation for level 1 to see if varying the buy message text in the game
 * increases in app purchases.
 *
 * Example:
 * @code
 * // get the AB Client to request variations
 * id<AIABTestClient> abTestClient = insights.abTestClient;
 *
 * [abTestClient variationsByProjectNames:[NSArray arrayWithObject:@"Level1Revenue"]
 *                  withCompletionHandler:^(id<AIVariationSet> variationSet, NSError* error) {
 *       if(error == nil) {
 *           // request an AIVariation out of the AIVariationSet
 *           id<AIVariation> revenueVariation = [variationSet variationForProjectName:@"Level1Revenue"];
 *           NSString* buyMessage = [revenueVariation variableAsString:@"buyMessage"
 *                                                         withDefault:@"Upgrade?"];
 *       }
 *   }];
 * @endcode
 */
@protocol AIABTestClient <NSObject>

/**
 * Attempts to retrieve the AIVariations requested in the NSArray of project names provided. The provided AICompletionHandler will
 * be invoked on the completion of the request.
 * <p>
 * This method returns immediately, even though all requested AIVariations have not been obtained.
 * The request will be performed in the background and will not block the calling thread. The provided AICompletionHandler
 * will receive the AIVariationSet served for the request.
 * </p>
 *
 * @param theProjectNames All projects that a variation should be allocated for.
 * @param completionHandler The completion handler block to be invoked on completion of the request. This block is called
                            on a background thread.
 */
@required
-(void) variationsByProjectNames:(NSArray *)theProjectNames withCompletionHandler:(AICompletionHandler) completionHandler;

@end
