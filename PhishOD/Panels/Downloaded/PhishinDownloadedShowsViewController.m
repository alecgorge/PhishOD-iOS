//
//  PhishinDownloadedShowsViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 8/1/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PhishinDownloadedShowsViewController.h"

#import "ShowViewController.h"
#import "PhishinAPI.h"
#import "ShowCell.h"

@interface PhishinDownloadedShowsViewController ()

@property (nonatomic) NSArray *shows;

@end

@implementation PhishinDownloadedShowsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Downloaded Shows";
    
    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(ShowCell.class)
											   bundle:NSBundle.mainBundle]
		 forCellReuseIdentifier:@"showCell"];
    
    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
}

- (void)refresh:(id)sender {
	[PhishinDownloadItem showsWithCachedTracks:^(NSArray *shows) {
		self.shows = [shows sortedArrayUsingComparator:^NSComparisonResult(PhishinShow *s1, PhishinShow *s2) {
			return [s2.date compare:s1.date];
		}];
		
		[self.tableView reloadData];
		[super refresh:sender];
	}];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.shows.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"showCell"
													 forIndexPath:indexPath];
    
    PhishinShow *show = self.shows[indexPath.row];
	[cell updateCellWithShow:show
				 inTableView:tableView];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	ShowCell *cell = [tableView dequeueReusableCellWithIdentifier:@"showCell"];
	
    PhishinShow *show = self.shows[indexPath.row];
	return [cell heightForCellWithShow:show
						   inTableView:tableView];
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
    PhishinShow *show = self.shows[indexPath.row];
	ShowViewController *vc = [ShowViewController.alloc initWithCompleteShow:show];
	
	[self.navigationController pushViewController:vc
										 animated:YES];
}

#pragma mark - Empty Data Set

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
    NSString *text = @"No Downloaded Shows :(";
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:22.0],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [NSAttributedString.alloc initWithString:text
                                         attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
    
    NSString *text = @"You can download individual tracks or complete shows from the show screen and then they will show up here.\n\nJust tap the cloud icon by the track to start the download.";
    
    NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
    paragraph.lineBreakMode = NSLineBreakByWordWrapping;
    paragraph.alignment = NSTextAlignmentCenter;
    
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:16.0],
                                 NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                 NSParagraphStyleAttributeName: paragraph};
    
    return [NSAttributedString.alloc initWithString:text
                                         attributes:attributes];
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
    return [UIImage imageNamed:@"music_128"];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
    BOOL empty = self.shows && self.shows.count == 0;
    
    if(empty) {
        self.tableView.tableFooterView = [UIView.alloc initWithFrame:CGRectZero];
    }
    
    return empty;
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView {
    return NO;
}

@end
