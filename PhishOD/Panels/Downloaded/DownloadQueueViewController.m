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

@property (nonatomic) NSOperationQueue *queue;
@property (nonatomic) FBKVOController *kvo;

@end

@implementation DownloadQueueViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
	self.title = @"Download Queue";
	
	[self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass(PHODTrackCell.class)
											   bundle:NSBundle.mainBundle]
		 forCellReuseIdentifier:@"trackCell"];
	
	self.queue = PhishinAPI.sharedAPI.downloader.queue;
    
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
	return [NSString stringWithFormat:@"%lu queued downloads", (unsigned long)self.queue.operations.count];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return self.queue.operations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
		 cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    PHODTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackCell"
														  forIndexPath:indexPath];
    
    if(indexPath.row < self.queue.operations.count) {
        PHODDownloadOperation *op = self.queue.operations[indexPath.row];
        PhishinDownloadItem *track = (PhishinDownloadItem *)op.item;
        
        [cell updateCellWithTrack:track.track
                      inTableView:tableView];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    PHODTrackCell *cell = [tableView dequeueReusableCellWithIdentifier:@"trackCell"];

	PHODDownloadOperation *op = self.queue.operations[indexPath.row];
	PhishinDownloadItem *track = (PhishinDownloadItem *)op.item;
	
    return [cell heightForCellWithTrack:track.track
							inTableView:tableView];
}

@end
