//
//  ShowDetailsViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 7/31/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "ShowDetailsViewController.h"

#import <SVWebViewController/SVWebViewController.h>
#import <DBGHTMLEntities/DBGHTMLEntityDecoder.h>

#import "VenueViewController.h"
#import "ShowViewController.h"

@interface ShowDetailsViewController ()

@property (nonatomic) ShowViewController *showVc;

@property (nonatomic, readonly) PhishinShow *show;
@property (nonatomic, readonly) PhishNetSetlist *setlist;

@end

@implementation ShowDetailsViewController

- (instancetype)initWithShowViewController:(ShowViewController *)showVc {
	if (self = [super initWithStyle:UITableViewStyleGrouped]) {
		self.showVc = showVc;
	}
	
	return self;
}

- (PhishinShow *)show {
	return self.showVc.show;
}

- (PhishNetSetlist *)setlist {
	return self.showVc.setlist;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return 6 + (self.show.taperNotes != nil);
}


- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if(indexPath.section == 0) {
		if(indexPath.row == 2) {
			static NSString *CellIdentifier = @"RatingCell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if(cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
											  reuseIdentifier:CellIdentifier];
			}
			
			cell.textLabel.text = @"Rating";
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
			
			if(self.setlist == nil) {
				cell.detailTextLabel.text = @"Loading...";
			}
			else {
				cell.detailTextLabel.text = [NSString stringWithFormat:@"%@/5.00 (%@ ratings)", self.setlist.rating, self.setlist.ratingCount];
			}
			
			return cell;
		}
		else if(indexPath.row == 1) {
			static NSString *CellIdentifier = @"RatingCell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if(cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
											  reuseIdentifier:CellIdentifier];
			}
			
			cell.textLabel.text = @"Venue";
			cell.detailTextLabel.text = self.show.venue.name;
			cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			return cell;
		}
		else if(indexPath.row == 4) {
			static NSString *CellIdentifier = @"InfoCell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if(cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											  reuseIdentifier:CellIdentifier];
			}
			
			if(self.setlist == nil) {
				cell.textLabel.text = @"Loading Reviews";
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			else {
				cell.textLabel.text = [NSString stringWithFormat:@"%lu Reviews", (unsigned long)self.setlist.reviews.count];
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
			
			return cell;
		}
		else if(indexPath.row == 3) {
			static NSString *CellIdentifier = @"InfoCell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if(cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											  reuseIdentifier:CellIdentifier];
			}
			
			if(self.setlist == nil) {
				cell.textLabel.text = @"Loading Setlist Notes";
				cell.accessoryType = UITableViewCellAccessoryNone;
			}
			else {
				cell.textLabel.text = @"Setlist Notes";
				cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			}
            
			return cell;
		}
		else if(indexPath.row == 5) {
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoCell"];
			
			if(cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											  reuseIdentifier:@"InfoCell"];
			}

			cell.textLabel.text = @"View on phish.net";
			cell.detailTextLabel.text = nil;
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			
			return cell;
		}
		else if(indexPath.row == 6) {
			static NSString *CellIdentifier = @"InfoCell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if(cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											  reuseIdentifier:CellIdentifier];
			}
			
            cell.textLabel.text = @"Taper Notes";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
			return cell;
		}
		else if(indexPath.row == 0) {
			static NSString *CellIdentifier = @"RatingCell";
			UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
			
			if(cell == nil) {
				cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
											  reuseIdentifier:CellIdentifier];
			}
			
			cell.textLabel.text = @"Features";
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.accessoryType = UITableViewCellAccessoryNone;
			
			if(self.show.sbd && self.show.remastered) {
				cell.detailTextLabel.text = @"Soundboard, Remastered";
			} else if(self.show.remastered) {
				cell.detailTextLabel.text = @"Remastered";
			} else if(self.show.sbd) {
				cell.detailTextLabel.text = @"Soundboard";
			} else {
				cell.detailTextLabel.text = @"None";
			}
			
			return cell;
		}
	}
	
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	if(indexPath.section == 0) {
		if(indexPath.row == 4) {
			ReviewsViewController *rev = [[ReviewsViewController alloc] initWithSetlist:self.setlist];
			[self.navigationController pushViewController:rev
												 animated:YES];
		}
		if(indexPath.row == 5) {
			SVWebViewController *rev = [SVWebViewController.alloc initWithAddress:[NSString stringWithFormat:@"http://phish.net/setlists/?d=%@", self.show.date]];
			[self.navigationController pushViewController:rev
												 animated:YES];
		}
		if(indexPath.row == 6) {
			LongStringViewController *vc = [LongStringViewController.alloc initWithString:self.show.taperNotes];
			vc.title = @"Taper Notes";
			vc.monospace = YES;
			[self.navigationController pushViewController:vc
												 animated:YES];
		}
		else if(indexPath.row == 3) {
			DBGHTMLEntityDecoder *decoder = DBGHTMLEntityDecoder.alloc.init;
			NSString *decoded = [decoder decodeString:self.setlist.setlistNotes];
			LongStringViewController *info = [LongStringViewController.alloc initWithString:decoded];
			info.title = @"Concert Notes";
			[self.navigationController pushViewController:info
												 animated:YES];
		}
		else if(indexPath.row == 1) {
			VenueViewController *vc = [[VenueViewController alloc] initWithVenue:self.show.venue];
			[self.navigationController pushViewController:vc
												 animated:YES];
		}
		
		return;
	}
}

@end
