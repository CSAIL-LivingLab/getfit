//
//  AppDelegate.m
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "AppDelegate.h"
#import "OpenSense.h"

#import "IntroPageVC.h"
#import "PageVC.h"
#import "MinuteTVC.h"

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // load intro screens on first launch
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    if (![defaults boolForKey:@"hasLaunchedBefore"]) {
    if (YES) {
        [defaults setBool:YES forKey:@"hasLaunchedBefore"];
        [defaults synchronize];
        
        [self loadIntroViews];
        
        [self.window makeKeyAndVisible];
    }


//        PageVC *pageVC = [[PageVC alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:NULL];
//        //UIPageViewControllerTransitionStylePageScroll
//    
//        UIPageControl *pageControl = [UIPageControl appearance];
//        pageControl.pageIndicatorTintColor = [UIColor grayColor];
//        pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
//    
//    
//        self.window.rootViewController = pageVC;
//        self.window.backgroundColor = [UIColor whiteColor];
//    
//        // add plus button
//        CGRect frame = [UIScreen mainScreen].bounds;
//        CGRect rightFrame = CGRectMake(frame.size.width - 170, 10, 200, 40);
//        UIButton *plusButton = [[UIButton alloc] initWithFrame:rightFrame];
//        [plusButton setTitle:@"add minutes +" forState:UIControlStateNormal];
//        [plusButton setTitleColor:[UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
//        [plusButton addTarget:self action:@selector(pushMinuteVC) forControlEvents:UIControlEventTouchUpInside];
//        [self.window.rootViewController.view addSubview:plusButton];
//        
//        [self.window makeKeyAndVisible];
    
    return YES;
}

- (void) loadIntroViews{
    
    IntroPageVC *introPageVC = [[IntroPageVC alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:NULL];
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor grayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];


    self.window.rootViewController = introPageVC;
    self.window.backgroundColor = [UIColor whiteColor];


}


- (void)pushMinuteVC {
    MinuteTVC *minuteTVC = [[MinuteTVC alloc] init];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:minuteTVC];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self.window.rootViewController presentViewController:navController animated:YES completion:nil];
}

@end










