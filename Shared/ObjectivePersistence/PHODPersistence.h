//
//  PHODPersistence.h
//  PhishOD
//
//  Created by Alec Gorge on 7/19/15.
//  Copyright (c) 2015 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PHODPersistence : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, readonly) NSString *path;

- (instancetype)initWithStoragePath:(NSString *)path;

- (void)setObject:(id<NSCoding>)obj
           forKey:(NSString *)key;

- (id)objectForKey:(NSString *)key;

@end
