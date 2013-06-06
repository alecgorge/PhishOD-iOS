//
//  YearViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "YearViewController.h"
#import <TDBadgedCell/TDBadgedCell.h>
#import "ShowViewController.h"

@interface YearViewController ()

@end

@implementation YearViewController

- (id)initWithYear:(PhishYear*)y {
    self = [super initWithStyle: UITableViewStylePlain];
    if (self) {
		self.year = y;
		
		YearViewController *i = self;
        [self.tableView addPullToRefreshWithActionHandler:^{
			[[PhishTracksAPI sharedAPI] fullYear:y
										 success:^(PhishYear *yy) {
											 i.year = yy;
											 [i.tableView reloadData];
											 
											 [i.tableView.pullToRefreshView stopAnimating];
										 } failure:REQUEST_FAILED(i.tableView)];
		}];
		
		[self.tableView triggerPullToRefresh];
		
		NSArray *itemArray = @[@"All", @"SDB", @"REMAST", @"Either", @"Both"];
        control = [[UISegmentedControl alloc] initWithItems:itemArray];
		control.segmentedControlStyle = UISegmentedControlStyleBar;
        control.frame = CGRectMake(10.0, 10.0, 305.0, 30.0);
		control.selectedSegmentIndex = 0;
		[control addTarget:self
					action:@selector(doFilterShows)
		  forControlEvents:UIControlEventValueChanged];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = self.year.year;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSArray *)doFilterShows {
	if(control.selectedSegmentIndex == 0) {
		filteredShows = self.year.shows;
	}
	else if(control.selectedSegmentIndex == 1) {
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF.isSoundboard == YES"];
		filteredShows = [self.year.shows filteredArrayUsingPredicate:pred];
	}
	else if(control.selectedSegmentIndex == 2) {
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF.isRemastered == YES"];
		filteredShows = [self.year.shows filteredArrayUsingPredicate:pred];
	}
	else if(control.selectedSegmentIndex == 3) {
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF.isRemastered == YES OR SELF.isSoundboard == YES"];
		filteredShows = [self.year.shows filteredArrayUsingPredicate:pred];
	}
	else if(control.selectedSegmentIndex == 4) {
		NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF.isRemastered == YES AND self.isSoundboard == YES"];
		filteredShows = [self.year.shows filteredArrayUsingPredicate:pred];
	}
	else {
		filteredShows = self.year.shows;
	}
	
	[self.tableView reloadData];
	
	return filteredShows;
}


- (NSArray *)filteredShows {
	if(filteredShows != nil) {
		return filteredShows;
	}
	else {
		return [self doFilterShows];
	}
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	if(self.year.hasShowsLoaded) {
		return [self filteredShows].count;
	}
	return 0;
}

- (UIView *)tableView:(UITableView *)tableView
viewForHeaderInSection:(NSInteger)section {
	if(section == 0) {
        UIToolbar *headerView = [[UIToolbar alloc] initWithFrame:CGRectMake(0,0, tableView.frame.size.width, 44)];
		
		CGRect newFrame = control.frame;
		newFrame.size.width = (305.0/320.0) * tableView.frame.size.width;
		control.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		control.frame = newFrame;
		
        [headerView setItems:@[[[UIBarButtonItem alloc] initWithCustomView:control]]];
        return headerView;
	}
	return nil;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForHeaderInSection:(NSInteger)section {
	if(section == 0) {
		return 44.0f;
	}
	return 0.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"BadgedCell";
    TDBadgedCell *cell = (TDBadgedCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if(cell == nil) {
		cell = [[TDBadgedCell alloc] initWithStyle:UITableViewCellStyleSubtitle
								   reuseIdentifier:CellIdentifier];
	}
	
	PhishShow *show = (PhishShow*)[self filteredShows][indexPath.row];
	cell.textLabel.text = [show.showDate stringByAppendingFormat:@" - %@", show.city];
	cell.detailTextLabel.text = show.location;
	cell.detailTextLabel.numberOfLines = 2;

	if(show.isSoundboard && show.isRemastered) {
		cell.badgeString = @"SDB+REMAST";
		cell.badgeColor = [UIColor darkGrayColor];
	} else if(show.isRemastered) {
		cell.badgeString = @"REMAST";
		cell.badgeColor = [UIColor blueColor];
	} else if(show.isSoundboard) {
		cell.badgeString = @"SBD";
		cell.badgeColor = [UIColor redColor];
	}
	
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	PhishShow *show = [self filteredShows][indexPath.row];
    [self.navigationController pushViewController:[[ShowViewController alloc] initWithShow: show]
										 animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return tableView.rowHeight * 1.3;
}

@end
