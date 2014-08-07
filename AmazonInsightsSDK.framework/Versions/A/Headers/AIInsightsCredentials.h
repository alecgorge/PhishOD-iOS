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
 * The AIInsightsCredentials protocol is implemented by all classes that can provide identification of the application
 * and keys for signing/encrypting data within the SDK. Currently the Public Key of an Amazon Insights Identifier also acts
 * as the Application key. All implementors must ensure they adhere to the NSCopying protocol
 * in order to be able to use the AIInsightsCredential implementation as a key for caching of AImazonInsights instances in
 * the SDK.
 */
@protocol AIInsightsCredentials <NSObject, NSCopying>

/**
 * Provides the application key.
 * @returns The application key.
 */
@required
@property (nonatomic, readonly) NSString* applicationKey;

/**
 * Provides the private key.
 * @returns The private key.
 */
@required
@property (nonatomic, readonly) NSString* privateKey;

@end
