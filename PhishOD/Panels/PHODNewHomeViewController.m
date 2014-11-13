//
//  PHODNewHomeViewController.m
//  PhishOD
//
//  Created by Alec Gorge on 11/12/14.
//  Copyright (c) 2014 Alec Gorge. All rights reserved.
//

#import "PHODNewHomeViewController.h"

@interface PHODNewHomeViewController ()

@property (weak, nonatomic) IBOutlet UIView *uiButtonContainer;
@property (weak, nonatomic) IBOutlet UIButton *uiButtonEverything;
@property (weak, nonatomic) IBOutlet UIButton *uiButtonDiscover;
@property (weak, nonatomic) IBOutlet UIButton *uiButtonPhishNet;
@property (weak, nonatomic) IBOutlet UIButton *uiButtonStats;
@property (weak, nonatomic) IBOutlet UIButton *uiButtonNowPlaying;

@property (nonatomic) NSArray *buttons;
@property (nonatomic) NSArray *menus;
@property (nonatomic) NSArray *submenus;

@property (nonatomic) NSInteger screenWidth;

@end

@implementation PHODNewHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.buttons = @[self.uiButtonEverything,
                     self.uiButtonDiscover,
                     self.uiButtonPhishNet,
                     self.uiButtonStats
                     ];
    
    self.menus = @[@[@"years", @"songs", @"venues", @"tours"],
                   @[@"top", @"random", @"playlists"],
                   @[@"my shows", @"blog", @"news"],
                   @[@"stats", @"favorites", @"recent"]
                   ];
    
    [self buildSubmenus];
    
    UIApplication.sharedApplication.statusBarStyle = UIStatusBarStyleDefault;
}

- (void)buildSubmenus {
    NSMutableArray *subs = NSMutableArray.array;
    NSInteger width = UIScreen.mainScreen.bounds.size.width;
    
    self.screenWidth = width;
  
    for (NSInteger i = 0; i < self.menus.count; i++) {
        NSArray *submenu = self.menus[i];
        UIButton *button  = self.buttons[i];
        
        UIView *container = [UIView.alloc initWithFrame:CGRectMake(-width * 2,
                                                                   button.frame.origin.y,
                                                                   width * 2,
                                                                   button.frame.size.height)];
        
        container.backgroundColor = COLOR_PHISH_GREEN;
        
        NSInteger buttonWidth = width / submenu.count;
        for(NSInteger j = 0; j < submenu.count; j++) {
            UIButton *b = [UIButton buttonWithType:UIButtonTypeCustom];
            b.frame = CGRectMake(width + j * buttonWidth,
                                 0,
                                 buttonWidth,
                                 button.frame.size.height);
            b.backgroundColor = COLOR_PHISH_GREEN;
            b.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
            
            [b setTitle:submenu[j]
               forState:UIControlStateNormal];
            
            [b setTitleColor:COLOR_PHISH_WHITE
                    forState:UIControlStateNormal];
            
            [container addSubview:b];
        }
        
        container.tag = button.tag = 1654 + i;
        
        [subs addObject:container];
        [self.uiButtonContainer addSubview:container];
        
        [button addTarget:self
                   action:@selector(menuItemTapped:)
         forControlEvents:UIControlEventTouchUpInside];
    }
    
    self.submenus = subs;
}

- (void)menuItemTapped:(UIButton *)btn {
    [UIView animateWithDuration:0.3
                          delay:0.0
         usingSpringWithDamping:0.6
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         for (UIView *container in self.submenus) {
                             CGRect f = container.frame;
                             if(container.tag == btn.tag) {
                                 f.origin.x = -self.screenWidth;
                             }
                             else {
                                 f.origin.x = -self.screenWidth * 2;
                             }
                             container.frame = f;
                         }
                         
                         for (UIButton *b in self.buttons) {
                             CGRect f = b.frame;
                             if(b != btn) {
                                 f.origin.x = 0;
                             }
                             else {
                                 f.origin.x = self.screenWidth;
                             }
                             b.frame = f;
                         }
                     }
                     completion:^(BOOL finished) {
                         
                     }];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES
                                             animated:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
