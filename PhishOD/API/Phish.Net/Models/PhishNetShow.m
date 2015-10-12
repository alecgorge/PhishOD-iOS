//
//  PhishNetShow.m
//  PhishOD
//
//  Created by Alec Gorge on 7/29/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PhishNetShow.h"

#import <FastImageCache/FICUtilities.h>

@interface PhishNetShow () {
    NSString *_uuid;
    NSString *_sourceuuid;
}

@end

@implementation PhishNetShow

+ (JSONKeyMapper *)keyMapper {
	return [JSONKeyMapper.alloc initWithDictionary:@{
													 @"showid": @"id",
													 @"showdate": @"dateString",
													 @"venuename": @"venueName",
													 @"city": @"city",
													 @"state": @"state",
													 @"country": @"country",
													 }];
}

- (NSString *)venue {
	return [NSString stringWithFormat:@"%@ in %@, %@", self.venueName, self.city, self.state];
}

- (NSURL *)albumArt {
	NSString *mediaDomain = [NSUserDefaults.standardUserDefaults objectForKey:@"media_domain"];
	
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/album_art/ph%@.jpg", mediaDomain, self.dateString]];
}

- (NSString *)displayText {
	return self.dateString;
}

- (NSString *)displaySubtext {
	return [NSString stringWithFormat:@"%@, %@", self.city, self.state];
}

#pragma mark - FICEntity Methods

- (NSString *)UUID {
    if(!_uuid) {
        CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString([@"phsho-" stringByAppendingString:self.dateString]);
        _uuid = FICStringWithUUIDBytes(UUIDBytes);
    }
    
    return _uuid;
}

- (NSString *)sourceImageUUID {
    if(!_sourceuuid) {
        CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString([@"phsho-source-" stringByAppendingString:self.dateString]);
        _sourceuuid = FICStringWithUUIDBytes(UUIDBytes);
    }
    
    return _sourceuuid;
}

- (NSURL *)sourceImageURLWithFormatName:(NSString *)formatName {
    NSURLComponents *components = [NSURLComponents componentsWithString:@"phod://shatter"];
    
    NSDictionary *queryDictionary = @{@"date": self.dateString,
                                      @"venue": self.venueName,
                                      @"location": [NSString stringWithFormat:@"%@, %@ %@", self.city, self.state, self.country] };
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
