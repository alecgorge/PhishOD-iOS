//
//  JamChartEntryViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 7/27/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "JamChartEntryViewController.h"

#import "ShowViewController.h"
#import "PhishNetJamChartEntry.h"
#import "IGDurationHelper.h"

typedef NS_ENUM(NSInteger, PhishODJamChartEntrySections) {
	PhishODJamChartEntrySectionPlay,
	PhishODJamChartEntrySectionInfo,
	PhishODJamChartEntrySectionNotes,
	PhishODJamChartEntrySectionCount
};

@interface JamChartEntryViewController ()

@property (nonatomic) PhishNetJamChartEntry *entry;
@property (nonatomic) PhishinTrack *track;

@end

@implementation JamChartEntryViewController

- (instancetype)initWithJamChartEntry:(PhishNetJamChartEntry *)entry
							 andTrack:(PhishinTrack *)track {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.entry = entry;
		self.track = track;
	}
	
	return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = self.track.title;
	
	[self.tableView registerClass:UITableViewCell.class
		   forCellReuseIdentifier:@"notes"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return PhishODJamChartEntrySectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(section == PhishODJamChartEntrySectionPlay) {
		return 2;
	}
	else if(section == PhishODJamChartEntrySectionInfo) {
		return 3;
	}
	
    return self.entry.notes.length > 0 ? 1 : 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    if(indexPath.section == PhishODJamChartEntrySectionNotes
	&& indexPath.row == 0) {
		cell = [tableView dequeueReusableCellWithIdentifier:@"notes"
											   forIndexPath:indexPath];
		
		cell.textLabel.text = self.entry.notes;
		cell.textLabel.numberOfLines = 0;
	}
	else {
		cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
		
		if(!cell) {
			cell = [UITableViewCell.alloc initWithStyle:UITableViewCellStyleValue1
										reuseIdentifier:@"cell"];
		}
	}
	
	if(indexPath.section == PhishODJamChartEntrySectionPlay) {
		if(indexPath.row == 0) {
			cell.textLabel.text = @"Play song";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
		else if(indexPath.row == 1) {
			cell.textLabel.text = @"View show";
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		}
	}
	else if(indexPath.section == PhishODJamChartEntrySectionInfo) {
		if(indexPath.row == 1) {
			cell.textLabel.text = @"Jam Chart Rating";
			
			if(self.entry.isKey) {
				cell.detailTextLabel.text = @"Key Jam";
			}
			else if(self.entry.isNoteworthy) {
				cell.detailTextLabel.text = @"Noteworthy Jam";
			}
			else {
				cell.detailTextLabel.text = @"Jam";
			}
			
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		else if(indexPath.row == 0) {
			cell.textLabel.text = @"Date";
			cell.detailTextLabel.text = self.track.show_date;
			
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
		else if(indexPath.row == 2) {
			cell.textLabel.text = @"Duration";
			cell.detailTextLabel.text = [IGDurationHelper formattedTimeWithInterval:self.track.duration];
			
			cell.accessoryType = UITableViewCellAccessoryNone;
		}
	}
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == PhishODJamChartEntrySectionNotes
	&& indexPath.row == 0) {
		CGFloat leftMargin = 20;
		CGFloat rightMargin = 20;
		
		CGSize constraintSize = CGSizeMake(tableView.bounds.size.width - leftMargin - rightMargin, MAXFLOAT);
		
		NSString *showDisText = self.entry.notes;
		CGRect labelSize = [showDisText boundingRectWithSize:constraintSize
													 options:NSStringDrawingUsesLineFragmentOrigin
												  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18.0]}
													 context:nil];
		
		return MAX(tableView.rowHeight, labelSize.size.height + 20);
	}
	
	return UITableViewAutomaticDimension;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
    if(indexPath.section != PhishODJamChartEntrySectionPlay) {
		return;
	}
		
	PhishinShow *show = [[PhishinShow alloc] init];
	show.id = (int)self.track.show_id;
	show.date = self.track.show_date;
	
	ShowViewController *showvc = [ShowViewController.alloc initWithShow:show];
	
	if(indexPath.row == 1) {
		showvc.autoplay = YES;
		showvc.autoplayTrackId = self.track.id;
	}
	
	[self.navigationController pushViewController:showvc
										 animated:YES];
}

@end
