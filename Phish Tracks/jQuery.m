//
//  jQuery.m
//  Brebeuf Jesuit
//
//  Created by Alec Gorge on 4/19/13.
//  Copyright (c) 2013 Alec Gorge. All rights reserved.
//

#import "jQuery.h"
#import "AppDelegate.h"

@implementation jQuery

@synthesize webview;

- (id)initWithHTML:(NSString *)html
		 andScript:(NSString *)relativePath {
	if(self = [super init]) {
		self.webview = [[UIWebView alloc] initWithFrame:CGRectMake(150, 150, 150, 150)];
		self.webview.delegate = self;
		
		script = relativePath;
		page = html;
		
		self.hold = self;
		
		if(![script hasSuffix:@".js"]) {
			script = [script stringByAppendingString: @".js"];
		}
		
//		[self debug];
	}
	return self;
}

- (void)start:(void(^)(NSError *, id))comp {
	completion = comp;
	
	NSString *payload = [NSString stringWithFormat:@"<script src='jquery2.min.js'></script><script src='NativeBridge.js'></script><script src='%@'></script><script src='jQueryAPI.js'></script>", script, nil];
	
	[self.webview loadHTMLString:[page stringByAppendingString:payload]
						 baseURL:[[NSBundle mainBundle] bundleURL]];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
	[self.webview stringByEvaluatingJavaScriptFromString:@""];
}

- (void)debug {
	[((AppDelegate*)[UIApplication sharedApplication].delegate).window.rootViewController.view addSubview:self.webview];
}

- (BOOL)webView:(UIWebView *)webView2
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType {
	NSString *requestString = [[request URL] absoluteString];
	if ([requestString hasPrefix:@"js-frame:"]) {
		
		NSArray *components = [requestString componentsSeparatedByString:@":"];
		
		NSString *function = (NSString*)[components objectAtIndex:1];
		int callbackId = [((NSString*)[components objectAtIndex:2]) intValue];
		
		[self handleCall:function callbackId:callbackId args:@[]];
		
		return NO;
	}
	
	return YES;
}

- (void)handleCall:(NSString*)functionName callbackId:(int)callbackId args:(NSArray*)args
{
	if ([functionName isEqualToString:@"ready"]) {
		if(completion != nil) {
			NSString *str = [self.webview stringByEvaluatingJavaScriptFromString:@"try { jquery_cb(jQuery); } catch(e) { error(e); }"];
			
			NSDictionary *d = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:[str dataUsingEncoding:NSUTF8StringEncoding]
																			 options:0
																			   error:nil];
			
			if([[d objectForKey:@"success"] boolValue]) {
				completion(nil, [d objectForKey:@"data"]);
			}
			else {
				NSError * err = [NSError errorWithDomain:@"com.alecgorge.Brebeuf-Jesuit"
													code:1
												userInfo:[d objectForKey:@"data"]];
				completion(err, nil);
			}
		}

	}
	else {
		dbug(@"Unimplemented method '%@'",functionName);
	}
}

@end
