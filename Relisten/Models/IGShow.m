//
//  IGShow.m
//  iguana
//
//  Created by Alec Gorge on 3/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "IGShow.h"

#import <NSObject-NSCoding/NSObject+NSCoding.h>
#import <EGOCache/EGOCache.h>

@implementation IGShow

+ (JSONKeyMapper*)keyMapper {
	JSONKeyMapper *j = [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
	return [JSONKeyMapper.alloc initWithJSONToModelBlock:^NSString *(NSString *keyName) {
		if ([keyName isEqualToString:@"description"]) {
			return @"showDescription";
		}
		return j.JSONToModelKeyBlock(keyName);
	}
										modelToJSONBlock:^NSString *(NSString *keyName) {
											return j.modelToJSONKeyBlock(keyName);
										}];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if([propertyName isEqualToString:@"recordingCount"]) {
        return YES;
    }
    
    return NO;
}

- (NSString *)cacheKey {
    return [IGShow cacheKeyForShowId:self.id];
}

- (IGShow *)cache {
    if(!self.id) {
        return nil;
    }
    
    [EGOCache.globalCache setObject:self
                             forKey:self.cacheKey];
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        [self autoDecode:aDecoder];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
    [self autoEncodeWithCoder:coder];
}

- (NSUInteger)hash {
    return self.id ^ [self.date hash];
}

- (BOOL)isEqual:(id)object {
    if(object && [object isKindOfClass:IGShow.class]) {
        IGShow *s = (IGShow *)object;
        
        return s.id == self.id;
    }
    
    return [super isEqual:object];
}

+ (NSString *)cacheKeyForShowId:(NSInteger)id {
    return [@"relisten.show." stringByAppendingString:@(id).stringValue];
}

+ (IGShow *)loadShowFromCacheForShowId:(NSInteger)id {
    return (IGShow *)[EGOCache.globalCache objectForKey:[self cacheKeyForShowId:id]];
}

@end
