//
//  CenterPanelAutoShrinker.m
//  Phish Tracks
//
//  Created by Alec Gorge on 1/25/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "NavigationControllerAutoShrinkerForNowPlaying.h"

#import "NowPlayingBarViewController.h"
#import "AppDelegate.h"
#import "AGMediaPlayerViewController.h"
#import "PHODTabbedHomeViewController.h"

@implementation NavigationControllerAutoShrinkerForNowPlaying


- (void)navigationController:(UINavigationController *)navigationController
       didShowViewController:(UIViewController *)viewController
					animated:(BOOL)animated {
	self.lastViewController = viewController;
	[self fixForViewController:viewController];
}

- (void)addBarToView:(UIView *)view {
    if([view viewWithTag:NowPlayingBarViewController.sharedInstance.view.tag] == nil) {
        UIView *v = NowPlayingBarViewController.sharedInstance.view;
        [v removeFromSuperview];
        
        CGRect r = v.bounds;
        
        r.origin.y = view.bounds.size.height - AppDelegate.sharedDelegate.tabs.tabBar.bounds.size.height;
        r.size.width = view.bounds.size.width;
        
//        if (NowPlayingBarViewController.sharedInstance.shouldShowBar) {
//            r.origin.y = view.bounds.size.height - r.size.height;
//        }
        
        v.frame = r;
        
        [view addSubview:v];
        [view bringSubviewToFront:v];
    }
    
	[view bringSubviewToFront:NowPlayingBarViewController.sharedInstance.view];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         if (NowPlayingBarViewController.sharedInstance.shouldShowBar) {
                             CGRect r = NowPlayingBarViewController.sharedInstance.view.frame;
                             r.origin.y = view.bounds.size.height - r.size.height - AppDelegate.sharedDelegate.tabs.tabBar.bounds.size.height;
                             NowPlayingBarViewController.sharedInstance.view.frame = r;
                         }
                         else {
                             CGRect r = NowPlayingBarViewController.sharedInstance.view.frame;
                             r.origin.y = view.bounds.size.height;
                             NowPlayingBarViewController.sharedInstance.view.frame = r;
                         }
                     }];
}

- (void)addBarToViewController:(UIViewController *)vc {
	[self addBarToView:AppDelegate.sharedDelegate.tabs.view];
}

- (void)fixForViewController:(UIViewController *)viewController {
    if (!NowPlayingBarViewController.sharedInstance.shouldShowBar) {
        return;
    }
    
    if([viewController isKindOfClass:UINavigationController.class]) {
		for(UIViewController *vc2 in ((UINavigationController*)viewController).viewControllers) {
			[self fixForViewController:vc2];
		}
	}
	else if([viewController isKindOfClass:[UITableViewController class]]) {
		UITableView *t = [(UITableViewController*)viewController tableView];
        
		UIEdgeInsets edges = t.contentInset;
        
		if((edges.bottom - AppDelegate.sharedDelegate.tabs.tabBar.bounds.size.height) < NowPlayingBarViewController.sharedInstance.view.bounds.size.height)
			edges.bottom += NowPlayingBarViewController.sharedInstance.view.bounds.size.height;
        
		t.contentInset = edges;
        
		edges = t.scrollIndicatorInsets;
        
		if((edges.bottom - AppDelegate.sharedDelegate.tabs.tabBar.bounds.size.height) < NowPlayingBarViewController.sharedInstance.view.bounds.size.height)
			edges.bottom += NowPlayingBarViewController.sharedInstance.view.bounds.size.height;
        
		t.scrollIndicatorInsets = edges;
	}
	else if ([viewController.view isKindOfClass:[UIScrollView class]]) {
		UIScrollView *t = (UIScrollView*)viewController.view;
        
		UIEdgeInsets edges = t.contentInset;
        
		if(edges.bottom < NowPlayingBarViewController.sharedInstance.view.bounds.size.height)
			edges.bottom += NowPlayingBarViewController.sharedInstance.view.bounds.size.height;
        
		t.contentInset = edges;
        
		edges = t.scrollIndicatorInsets;
        
		if(edges.bottom < NowPlayingBarViewController.sharedInstance.view.bounds.size.height)
			edges.bottom += NowPlayingBarViewController.sharedInstance.view.bounds.size.height;
        
		t.scrollIndicatorInsets = edges;
	}
}

@end
