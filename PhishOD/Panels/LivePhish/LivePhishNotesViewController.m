//
//  LivePhishNotesViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 7/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LivePhishNotesViewController.h"

#import "LivePhishAPI.h"

@interface LivePhishNotesViewController ()

@property (nonatomic) LivePhishCompleteContainer *container;

@end

@implementation LivePhishNotesViewController

- (instancetype)initWithCompleteContainer:(LivePhishCompleteContainer *)container {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.container = container;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"Notes";
    
    [self.tableView registerClass:UITableViewCell.class
           forCellReuseIdentifier:@"cell"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.container.notes.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section {
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"
                                                            forIndexPath:indexPath];
    
    LivePhishNote *note = self.container.notes[indexPath.section];
    cell.textLabel.text = note.cleansedNote;
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.font = [UIFont systemFontOfSize:14.0];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView
heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    LivePhishNote *note = self.container.notes[indexPath.section];

    CGRect r = [note.cleansedNote boundingRectWithSize:CGSizeMake(tableView.bounds.size.width - 30, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                            attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14.0]}
                                               context:nil];
    
    return MAX(tableView.rowHeight, r.size.height + 24);
}

@end
