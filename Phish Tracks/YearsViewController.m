//
//  YearsViewController.m
//  Phish Tracks
//
//  Created by Alec Gorge on 6/3/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "YearsViewController.h"
#import "YearViewController.h"

@interface YearsViewController ()

@end

@implementation YearsViewController

@synthesize years;

- (id)init {
    self = [super initWithStyle: UITableViewStylePlain];
    if (self) {
		self.years = @[];
		
		YearsViewController *i = self;
        [self.tableView addPullToRefreshWithActionHandler:^{
			[[PhishTracksAPI sharedAPI] years:^(NSArray *phishYears) {
				i.years = phishYears;
				[i.tableView reloadData];
				
				[i.tableView.pullToRefreshView stopAnimating];
			}
									  failure:REQUEST_FAILED(i.tableView)];
		}];
		
		[self.tableView triggerPullToRefresh];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

	self.title = @"Years";
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
	return years.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
	if(cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									  reuseIdentifier:CellIdentifier];
	}
	
	cell.textLabel.text = ((PhishYear*)years[indexPath.row]).year;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.navigationController pushViewController:[[YearViewController alloc] initWithYear:self.years[indexPath.row]]
										 animated:YES];
	
	[self.tableView deselectRowAtIndexPath:indexPath
								  animated:YES];
}

@end
