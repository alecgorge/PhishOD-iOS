//
//  LongStringTableViewCell.m
//  PhishOD
//
//  Created by Alec Gorge on 8/3/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "LongStringTableViewCell.h"

#import <TTTAttributedLabel/TTTAttributedLabel.h>
#import <SVWebViewController/SVWebViewController.h>

@interface LongStringTableViewCell () <TTTAttributedLabelDelegate>

@property (nonatomic) TTTAttributedLabel *attributedLabel;

@end

@implementation LongStringTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style
                    reuseIdentifier:reuseIdentifier]) {
        self.attributedLabel = [TTTAttributedLabel.alloc initWithFrame:CGRectMake(15, 10, 290, 24)];
        self.attributedLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        self.attributedLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
        self.attributedLabel.delegate = self;
        
        [self.contentView addSubview:self.attributedLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.attributedLabel.frame = CGRectMake(15, 10, self.bounds.size.width - (15 * 2), self.bounds.size.height - (10 * 2));
    
    [self setNeedsDisplay];
}

- (void)updateCellWithString:(NSString *)s
                     andFont:(UIFont *)font {
    self.textLabel.text = s;
    self.textLabel.numberOfLines = 0;
	self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.textLabel.font = font == nil ? [UIFont systemFontOfSize: UIFont.systemFontSize] : font;
}

- (void)updateCellWithAttributedString:(NSAttributedString *)a {
    self.attributedLabel.attributedText = a;
    self.attributedLabel.numberOfLines = 0;
	self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.attributedLabel.font = [UIFont systemFontOfSize: UIFont.systemFontSize];
}

- (void)updateCellWithHTML:(NSString *)s {
    NSMutableAttributedString *a = [[NSAttributedString alloc] initWithData:[s dataUsingEncoding:NSUTF8StringEncoding]
                                                                    options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                              NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                         documentAttributes:nil
                                                                      error:nil].mutableCopy;

    [a addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize: UIFont.systemFontSize]}
               range:NSMakeRange(0, a.length)];

    [self updateCellWithAttributedString:a];
}

- (CGFloat)heightForCellWithString:(NSString *)text
                           andFont:(UIFont *)font
                       inTableView:(UITableView *)tableView {
	font = font == nil ? [UIFont systemFontOfSize: UIFont.systemFontSize] : font;
    
    // Get a CGSize for the width and, effectively, unlimited height
	CGSize constraint = CGSizeMake(tableView.frame.size.width - (15.0f * 2), CGFLOAT_MAX);
	
	// Get the size of the text given the CGSize we just made as a constraint
	CGRect rect = [text boundingRectWithSize:constraint
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{NSFontAttributeName: font}
                                  context:nil];
	
	// Get the height of our measurement, with a minimum of 44 (standard cell size)
	CGFloat height = MAX(rect.size.height, (tableView.rowHeight < 0 ? 44.0 : tableView.rowHeight));
	
	// return the height, with a bit of extra padding in
	return height + (10.0f * 2);
}

- (CGFloat)heightForCellWithAttributedString:(NSAttributedString *)text
                                 inTableView:(UITableView *)tableView {
    // Get a CGSize for the width and, effectively, unlimited height
	CGSize constraint = CGSizeMake(tableView.frame.size.width - (15.0f * 2), CGFLOAT_MAX);
	
	// Get the size of the text given the CGSize we just made as a constraint
	CGRect rect = [text boundingRectWithSize:constraint
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                     context:nil];
	
	// Get the height of our measurement, with a minimum of 44 (standard cell size)
	CGFloat height = MAX(rect.size.height, (tableView.rowHeight < 0 ? 44.0 : tableView.rowHeight));
	
	// return the height, with a bit of extra padding in
	return height + (10.0f * 2);
}

- (CGFloat)heightForCellWithHTML:(NSString *)s
                     inTableView:(UITableView *)tableView {
    NSMutableAttributedString *a = [[NSAttributedString alloc] initWithData:[s dataUsingEncoding:NSUTF8StringEncoding]
                                                                    options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                                                              NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                         documentAttributes:nil
                                                                      error:nil].mutableCopy;
    
    [a addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize: UIFont.systemFontSize]}
               range:NSMakeRange(0, a.length)];

    return [self heightForCellWithAttributedString:a
                                       inTableView:tableView];
}

- (void)attributedLabel:(TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url {
    SVWebViewController *vc = [SVWebViewController.alloc initWithURL:url];
    
    [self.navigationController pushViewController:vc
                                         animated:YES];
}

@end
