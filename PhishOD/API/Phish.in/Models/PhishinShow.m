//
//  PhishinShow.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/4/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishinShow.h"

#import <MediaPlayer/MediaPlayer.h>
#import <NSObject-NSCoding/NSObject+NSCoding.h>
#import "PHODPersistence.h"

#import <FastImageCache/FICUtilities.h>

@interface PhishinShow () {
    MPMediaItemArtwork *_artwork;
    BOOL _artworkRequested;
    
    NSString *_uuid;
    NSString *_sourceuuid;
}

@end

@implementation PhishinShow

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
		if([dict isKindOfClass:NSNull.class] || [dict[@"missing"] boolValue]) {
			self.missing = YES;
			return self;
		}
		
        self.id = [dict[@"id"] intValue];
		self.date = dict[@"date"];
		self.duration = [dict[@"duration"] integerValue];
		self.incomplete = [dict[@"incomplete"] boolValue];
		self.missing = [dict[@"missing"] boolValue];
		self.sbd = [dict[@"sbd"] boolValue];
		self.remastered = [dict[@"remastered"] boolValue];
		self.tour_id = [dict[@"tour_id"] intValue];
		self.venue_id = [dict[@"venue_id"] intValue];
		self.likes_count = [dict[@"likes_count"] intValue];
		self.taperNotes = [dict[@"taper_notes"] isKindOfClass:NSNull.class] ? nil : dict[@"taper_notes"];
		
		if (dict[@"venue"]) {
			self.venue = [[PhishinVenue alloc] initWithDictionary:dict[@"venue"]];
		}
		else {
			self.venue_name = dict[@"venue_name"];
			self.location = dict[@"location"];
		}
		
		if (dict[@"tracks"]) {
			self.tracks = [dict[@"tracks"] map:^id(id object) {
				return [[PhishinTrack alloc] initWithDictionary:object andShow:self];
			}];
			
			self.sets = [[dict[@"tracks"] valueForKeyPath:@"@distinctUnionOfObjects.set"] sortedArrayUsingComparator:^NSComparisonResult(NSString *obj1, NSString *obj2) {
                if ([obj1 isEqualToString:@"S"] || [obj2 isEqualToString:@"E"]) {
                    return NSOrderedAscending;
                }
                else if ([obj1 isEqualToString:@"E"] || [obj2 isEqualToString:@"S"]) {
                    return NSOrderedDescending;
                }
                
                return [obj1 compare:obj2];
            }];
			self.sets = [self.sets map:^id(id object) {
				NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF.set == %@", object];

				NSString *name;
				if([object caseInsensitiveCompare:@"E"] == NSOrderedSame) {
					name = @"Encore";
				}
                else if([object caseInsensitiveCompare:@"S"] == NSOrderedSame) {
                    name = @"Soundcheck";
                }
				else {
					name = [@"Set " stringByAppendingString:object];
				}
				
				return [[PhishinSet alloc] initWithTitle:name
											   andTracks:[self.tracks filteredArrayUsingPredicate:pred]];
			}];
		}
		else {
			self.tracks = @[];
			self.sets = @[];
		}
    }
    return self;
}

- (NSString *)venue_name {
	if (_venue_name) {
		return _venue_name;
	}
	
	return self.venue.name;
}

- (NSString *)location {
	if (_location) {
		return _location;
	}
	
	return self.venue.location;
}

- (NSString *)fullLocation {
	return [self.location stringByAppendingFormat:@" - %@", self.venue_name];
}

- (MPMediaItemArtwork *)albumArt {
    if(_artwork == nil && _artworkRequested == NO) {
        PhishAlbumArtCache *c = PhishAlbumArtCache.sharedInstance;
        
        [c.sharedCache retrieveImageForEntity:self
                               withFormatName:PHODImageFormatFull
                              completionBlock:^(id<FICEntity> entity, NSString *formatName, UIImage *image) {
                                  _artwork = [MPMediaItemArtwork.alloc initWithImage:image];
                              }];
    }
    
    return _artwork;
}

- (NSString *)displayText {
	return self.date;
}

- (NSString *)displaySubtext {
	return self.location;
}

- (NSString *)cacheKey {
	return [PhishinShow cacheKeyForShowDate:self.date];
}

- (PhishinShow *)cache {
    if(!self.date) {
        return nil;
    }
    
	[PHODPersistence.sharedInstance setObject:self
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
    if(object && [object isKindOfClass:PhishinShow.class]) {
        PhishinShow *s = (PhishinShow *)object;
        
        return    s.id == self.id
               && [s.date isEqual:self.date]
               && s.duration == self.duration
               && s.sbd == self.sbd
               && s.remastered == self.remastered;
    }

    return [super isEqual:object];
}

+ (NSString *)cacheKeyForShowDate:(NSString *)date {
	return [@"phishin.show." stringByAppendingString:date];
}

+ (PhishinShow *)loadShowFromCacheForShowDate:(NSString *)date {
	return (PhishinShow *)[PHODPersistence.sharedInstance objectForKey:[self cacheKeyForShowDate:date]];
}

#pragma mark - FICEntity Methods

- (NSString *)UUID {
    if(!_uuid) {
        CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString([@"phin-" stringByAppendingString:self.date]);
        _uuid = FICStringWithUUIDBytes(UUIDBytes);
    }
    
    return _uuid;
}

- (NSString *)sourceImageUUID {
    if(!_sourceuuid) {
        CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString([@"phin-source-" stringByAppendingString:self.date]);
        _sourceuuid = FICStringWithUUIDBytes(UUIDBytes);
    }
    
    return _sourceuuid;
}

- (NSURL *)sourceImageURLWithFormatName:(NSString *)formatName {
    NSURLComponents *components = [NSURLComponents componentsWithString:@"phod://shatter"];
    
    NSDictionary *queryDictionary = @{@"date": self.date,
                                      @"venue": self.venue_name ?: self.venue.name,
                                      @"location": self.location ?: self.venue.location };
    NSMutableArray *queryItems = [NSMutableArray array];
    for (NSString *key in queryDictionary) {
        [queryItems addObject:[NSURLQueryItem queryItemWithName:key value:queryDictionary[key]]];
    }
    
    components.queryItems = queryItems;
    
    return components.URL;
}

- (FICEntityImageDrawingBlock)drawingBlockForImage:(UIImage *)image
                                    withFormatName:(NSString *)formatName {
    FICEntityImageDrawingBlock drawingBlock = ^(CGContextRef context, CGSize contextSize) {
        CGRect contextBounds = CGRectZero;
        contextBounds.size = contextSize;
        CGContextClearRect(context, contextBounds);
        CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
        
        UIGraphicsPushContext(context);
        [image drawInRect:contextBounds];
        UIGraphicsPopContext();
    };
    
    return drawingBlock;
}

@end
