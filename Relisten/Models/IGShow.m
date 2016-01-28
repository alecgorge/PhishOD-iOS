//
//  IGShow.m
//  iguana
//
//  Created by Alec Gorge on 3/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "IGShow.h"

#import "PHODPersistence.h"
#import "IGArtist.h"

@implementation IGShow

#pragma mark - JSONModel

+ (JSONKeyMapper*)keyMapper {
	JSONKeyMapper *j = [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
	return [JSONKeyMapper.alloc initWithJSONToModelBlock:^NSString *(NSString *keyName) {
		if ([keyName isEqualToString:@"showDescription"]) {
			return @"description";
		}
        else if([keyName isEqualToString:@"description"]) {
            return @"showDescription";
        }
		return j.JSONToModelKeyBlock(keyName);
	}
										modelToJSONBlock:^NSString *(NSString *keyName) {
                                            if ([keyName isEqualToString:@"showDescription"]) {
                                                return @"description";
                                            }
                                            else if([keyName isEqualToString:@"description"]) {
                                                return @"showDescription";
                                            }
											return j.modelToJSONKeyBlock(keyName);
										}];
}

+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    if([propertyName isEqualToString:@"recordingCount"]
    || [propertyName isEqualToString:@"ArtistId"]) {
        return YES;
    }
    
    return NO;
}

#pragma makr - Caching

- (void)setArtist:(IGArtist<Ignore> *)artist {
    _artist = artist;
    self.ArtistId = artist.id;
}

- (NSString *)cacheKey {
    return [IGShow cacheKeyForShowId:self.id];
}

- (IGShow *)cache {
    if(!self.id) {
        return nil;
    }
    
    [PHODPersistence.sharedInstance setObject:self
                                       forKey:self.cacheKey];
    
    return self;
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

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        for (IGTrack *t in self.tracks) {
            t.show = self;
        }
    }
    return self;
}

+ (NSString *)cacheKeyForShowId:(NSInteger)id {
    return [@"relisten.show." stringByAppendingString:@(id).stringValue];
}

+ (IGShow *)loadShowFromCacheForShowId:(NSInteger)id {
    return (IGShow *)[PHODPersistence.sharedInstance objectForKey:[self cacheKeyForShowId:id]];
}

@end
