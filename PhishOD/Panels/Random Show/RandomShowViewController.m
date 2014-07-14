//
//  RandomShowViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 10/29/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "RandomShowViewController.h"

@implementation RandomShowViewController

- (instancetype)init {
	if (self = [super initWithStyle:UITableViewStylePlain]) {
		self.title = @"Random Show";
	}
	return self;
}

- (void)refresh:(id)sender {
	[[PhishinAPI sharedAPI] randomShow:^(PhishinShow *ss) {
		self.show = ss;
		
		[[PhishNetAPI sharedAPI] setlistForDate:self.show.date
										success:^(PhishNetSetlist *s) {
											self.setlist = s;
											[self.tableView reloadData];
										}
										failure:REQUEST_FAILED(self.tableView)];
		
		self.title = self.show.date;
		[self.tableView reloadData];
		
		[super refresh:sender];
	}
							   failure:REQUEST_FAILED(self.tableView)];
}

@end
