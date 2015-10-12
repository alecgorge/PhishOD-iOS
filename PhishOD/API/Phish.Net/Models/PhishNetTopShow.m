//
//  PhishNetTopShow.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/5/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishNetTopShow.h"

#import <FastImageCache/FICUtilities.h>

@interface PhishNetTopShow () {
    NSString *_uuid;
    NSString *_sourceuuid;
}

@end

@implementation PhishNetTopShow

@synthesize rating;
@synthesize ratingCount;

- (NSURL *)albumArt {
	NSString *mediaDomain = [NSUserDefaults.standardUserDefaults objectForKey:@"media_domain"];
	
	return [NSURL URLWithString:[NSString stringWithFormat:@"http://%@/album_art/ph%@.jpg", mediaDomain, self.showDate]];
}

- (NSString *)displayText {
	return self.showDate;
}

- (NSString *)displaySubtext {
	return [NSString stringWithFormat:@"%@ (%@ votes)", self.rating, self.ratingCount];
}

- (NSString *)UUID {
    if(!_uuid) {
        CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString([@"ptop-" stringByAppendingString:self.showDate]);
        _uuid = FICStringWithUUIDBytes(UUIDBytes);
    }
    
    return _uuid;
}

- (NSString *)sourceImageUUID {
    if(!_sourceuuid) {
        CFUUIDBytes UUIDBytes = FICUUIDBytesFromMD5HashOfString([@"ptop-source-" stringByAppendingString:self.showDate]);
        _sourceuuid = FICStringWithUUIDBytes(UUIDBytes);
    }
    
    return _sourceuuid;
}

- (NSURL *)sourceImageURLWithFormatName:(NSString *)formatName {
    NSURLComponents *components = [NSURLComponents componentsWithString:@"phod://shatter"];
    
    NSDictionary *queryDictionary = @{@"date": self.displayText,
                                      @"venue": self.displaySubtext,
                                      @"location": @"" };
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
