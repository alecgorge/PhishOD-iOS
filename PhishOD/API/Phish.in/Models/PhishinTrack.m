//
//  PhishinTrack.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/5/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "PhishinTrack.h"

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
    }
    return self;
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

@end
