//
//  jQuery.h
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 4/19/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface jQuery : NSObject<UIWebViewDelegate> {
	void(^completion)(NSError *, id);
	NSString *script;
	NSString *page;
}

@property (nonatomic, strong) UIWebView *webview;
@property (nonatomic, strong) id hold;

- (id)initWithHTML:(NSString *)html andScript:(NSString*)relativePath;
- (void)start:(void(^)(NSError *, id))comp;
- (void)debug;

@end
