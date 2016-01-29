//
//  DownloadQueueViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 8/1/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "DownloadQueueViewController.h"

#import <KVOController/FBKVOController.h>

#import "PHODTrackCell.h"

@interface DownloadQueueViewController ()

@property (nonatomic) NSArray<PhishinDownloadItem *> *queue;
@property (nonatomic) FBKVOController *kvo;

@end

@implementation DownloadQueueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.title = @"Download Queue";
	
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(PHODTrackCell.class)
											   bundle:NSBundle.mainBundle]
		 forCellReuseIdentifier:@"trackCell"];
	
	self.queue = (NSArray<PhishinDownloadItem *> *)PhishinAPI.sharedAPI.downloader.downloadQueue;
    
    self.kvo = [FBKVOController.alloc initWithObserver:self];
    
    [self.kvo observe:self.queue
              keyPath:@"count"
              options:NSKeyValueObservingOptionNew
                block:^(id observer, id object, NSDictionary *change) {
                    [self.tableView reloadData];
                }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section {
	return [NSString stringWithFormat:@"%lu queued downloads", (unsigned long)self.queue.count];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.queue.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PHODTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackCell"
														  forIndexPath:indexPath];
    
    if(indexPath.row < self.queue.count) {
        PhishinDownloadItem *track = self.queue[indexPath.row];
        
        [cell updateCellWithTrack:track.track
                      inTableView:tableView];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PHODTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackCell"];

    PhishinDownloadItem *track = self.queue[indexPath.row];
	
    return [cell heightForCellWithTrack:track.track
							inTableView:tableView];
}

@end
