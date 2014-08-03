//
//  PhishinTrack.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/5/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishinTrack.h"

#import "PhishinShow.h"

@implementation PhishinTrack

- (id)initWithDictionary:(NSDictionary *)dict andShow:(PhishinShow *)show {
    self = [super init];
    if (self) {
        self.id = [dict[@"id"] intValue];
		self.title = dict[@"title"];
		self.position = [dict[@"position"] intValue];
		self.duration = [dict[@"duration"] intValue] / 1000.0f;
		self.set = dict[@"set"];
		self.likes_count = [dict[@"likes_count"] intValue];
		self.slug = dict[@"slug"];
		self.mp3 = [NSURL URLWithString:dict[@"mp3"]];
		self.song_ids = dict[@"song_ids"];
		self.show_date = dict[@"show_date"];
		self.show_id = [dict[@"show_id"] intValue];
		
		self.show = show;
        
        if(show == nil && dict[@"show_id"] && dict[@"show_date"]) {
            show = PhishinShow.alloc.init;
            show.id = [dict[@"show_id"] intValue];
            show.date = dict[@"show_date"];
            
            self.show = show;
        }
    }
    return self;
}

- (BOOL)isCacheable {
	return YES;
}

- (BOOL)isCached {
	return self.downloadItem.isCached;
}

- (BOOL)isDownloadingOrQueued {
	return [self.downloader isTrackDownloadedOrQueued:self.downloadItem];
}

- (NSURL *)cachedFile {
    return self.downloadItem.cachedFile;
}

- (PhishinDownloader *)downloader {
	return PhishinAPI.sharedAPI.downloader;
}

- (PHODDownloadItem *)downloadItem {
    return [PhishinDownloadItem.alloc initWithTrack:self
                                            andShow:self.show];
}

- (NSDate *)date {
	static NSDateFormatter *formatter = nil;
	
	if(formatter == nil) {
		formatter = NSDateFormatter.alloc.init;
		formatter.dateFormat = @"yyyy-MM-dd";
	}
	
	if(_date == nil) {
		_date = [formatter dateFromString:self.show_date];
	}
	
	return _date;
}

- (void)setShow_date:(NSString *)show_date {
	_show_date = show_date;
	
	self.index = [self.show_date substringWithRange:NSMakeRange(2, 2)];
}

- (NSString *)shareURLWithPlayedTime:(NSTimeInterval)elapsed {
	NSString *url = [NSString stringWithFormat:@"http://phish.in/%@/%@", self.show.date, self.slug];
	if(elapsed > 0) {
		url = [url stringByAppendingFormat:@"?t=%dm%ds", (int)floor(elapsed / 60), (int)((elapsed - floor(elapsed)) * 60)];
	}
	return url;
}

- (NSInteger)track {
    return _position;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
	if (self = [super init]) {
		self.id 			= [aDecoder decodeIntegerForKey:@"id"];
		self.title 			= [aDecoder decodeObjectForKey:@"title"];
		self.position 		= [aDecoder decodeIntegerForKey:@"position"];
		self.duration 		= [aDecoder decodeDoubleForKey:@"duration"];
		self.set 			= [aDecoder decodeObjectForKey:@"set"];
		self.likes_count 	= [aDecoder decodeIntegerForKey:@"likes_count"];
		self.show_date 		= [aDecoder decodeObjectForKey:@"show_date"];
		self.show_id 		= [aDecoder decodeIntegerForKey:@"show_id"];
		self.slug 			= [aDecoder decodeObjectForKey:@"slug"];
		self.mp3 			= [aDecoder decodeObjectForKey:@"mp3"];
		self.song_ids 		= [aDecoder decodeObjectForKey:@"song_ids"];
		self.index 			= [aDecoder decodeObjectForKey:@"index"];
		self.date 			= [aDecoder decodeObjectForKey:@"date"];
		self.show 			= [aDecoder decodeObjectForKey:@"show"];
	}
	return self;
}

-(void)encodeWithCoder:(NSCoder *)coder {
	[coder encodeInteger:self.id forKey:@"id"];
	[coder encodeObject:self.title forKey:@"title"];
	[coder encodeInteger:self.position forKey:@"position"];
	[coder encodeDouble:self.duration forKey:@"duration"];
	[coder encodeObject:self.set forKey:@"set"];
	[coder encodeInteger:self.likes_count forKey:@"likes_count"];
	[coder encodeObject:self.show_date forKey:@"show_date"];
	[coder encodeInteger:self.show_id forKey:@"show_id"];
	[coder encodeObject:self.slug forKey:@"slug"];
	[coder encodeObject:self.mp3 forKey:@"mp3"];
	[coder encodeObject:self.song_ids forKey:@"song_ids"];
	[coder encodeObject:self.index forKey:@"index"];
	[coder encodeObject:self.date forKey:@"date"];
	[coder encodeObject:self.show forKey:@"show"];
}

@end
