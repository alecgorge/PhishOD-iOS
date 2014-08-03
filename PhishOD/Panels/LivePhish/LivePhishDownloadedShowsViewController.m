//
//  LivePhishDownloadedShowsViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 8/2/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LivePhishDownloadedShowsViewController.h"

#import <SDWebImage/UIImageView+WebCache.h>

#import "LargeImageTableViewCell.h"
#import "ShowViewController.h"
#import "PhishinAPI.h"
#import "LivePhishContainerViewController.h"

@interface LivePhishDownloadedShowsViewController ()

@property (nonatomic) NSArray *shows;

@end

@implementation LivePhishDownloadedShowsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.title = @"Downloaded Shows";

    self.tableView.emptyDataSetSource = self;
    self.tableView.emptyDataSetDelegate = self;
}

- (void)refresh:(id)sender {
	[LivePhishDownloadItem showsWithCachedTracks:^(NSArray *shows) {
		self.shows = [shows sortedArrayUsingComparator:^NSComparisonResult(LivePhishCompleteContainer *s1, LivePhishCompleteContainer *s2) {
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

- (UIImage *)placeholderImage {
    static UIImage *img;
    
    if(img == nil) {
        CGSize size = CGSizeMake(88.0f, 88.0f);
        UIGraphicsBeginImageContextWithOptions(size, YES, 0);
        [[UIColor whiteColor] setFill];
        UIRectFill(CGRectMake(0, 0, size.width, size.height));
        img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    return img;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"subtitle"];
    
    if(!cell) {
        cell = [LargeImageTableViewCell.alloc initWithStyle:UITableViewCellStyleSubtitle
                                            reuseIdentifier:@"subtitle"];
    }
    
    LivePhishCompleteContainer *cont = self.shows[indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    cell.textLabel.text = cont.displayText;
    cell.detailTextLabel.text = cont.displaySubtext;
    cell.detailTextLabel.numberOfLines = 3;
    
    [cell.imageView sd_setImageWithURL:cont.imageURL
                      placeholderImage:self.placeholderImage];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 88.0f;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    LivePhishCompleteContainer *cont = self.shows[indexPath.row];
    [cont.songs each:^(LivePhishSong *song) {
        song.container = cont;
    }];
    
    LivePhishContainerViewController *vc = [LivePhishContainerViewController.alloc initWithCompleteContainer:cont];
    
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
