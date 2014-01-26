//
//  CenterPanelAutoShrinker.m
//  Phish Tracks
//
//  Created by Alec Gorge on 1/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "NavigationControllerAutoShrinkerForNowPlaying.h"
#import "NowPlayingBarViewController.h"
#import "StreamingMusicViewController.h"

@implementation NavigationControllerAutoShrinkerForNowPlaying

- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
					animated:(BOOL)animated {
    if([navigationController.view viewWithTag:NowPlayingBarViewController.sharedNowPlayingBar.view.tag] == nil) {
        UIView *v = NowPlayingBarViewController.sharedNowPlayingBar.view;
        [v removeFromSuperview];
        
        CGRect r = v.bounds;
        
        r.origin.y = navigationController.view.bounds.size.height;
        r.size.width = navigationController.view.bounds.size.width;
        
        if (NowPlayingBarViewController.sharedNowPlayingBar.shouldShowBar) {
            r.origin.y = navigationController.view.bounds.size.height - r.size.height;
        }
        
        v.frame = r;
        
        [navigationController.view addSubview:v];
        [navigationController.view bringSubviewToFront:v];
    }
    
    self.lastViewController = viewController;
    
    if(!NowPlayingBarViewController.sharedNowPlayingBar.shouldShowBar) {
        return;
    }
    
    [self fixForViewController:viewController];
}

- (void)fixForViewController:(UIViewController *)viewController {
    if([viewController isKindOfClass:[UITableViewController class]]) {
		UITableView *t = [(UITableViewController*)viewController tableView];
		
		UIEdgeInsets edges = t.contentInset;
		edges.bottom += NowPlayingBarViewController.sharedNowPlayingBar.view.bounds.size.height;
		t.contentInset = edges;
        
		edges = t.scrollIndicatorInsets;
		edges.bottom += NowPlayingBarViewController.sharedNowPlayingBar.view.bounds.size.height;
		t.scrollIndicatorInsets = edges;
	}
	else if ([viewController.view isKindOfClass:[UIScrollView class]]) {
		UIScrollView *t = (UIScrollView*)viewController.view;
        
		UIEdgeInsets edges = t.contentInset;
		edges.bottom += NowPlayingBarViewController.sharedNowPlayingBar.view.bounds.size.height;
		t.contentInset = edges;
		
		edges = t.scrollIndicatorInsets;
		edges.bottom += NowPlayingBarViewController.sharedNowPlayingBar.view.bounds.size.height;
		t.scrollIndicatorInsets = edges;
	}
}

@end
