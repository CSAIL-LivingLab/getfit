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

//#import "PageVC.h"
#import "ExerciseVC.h"
#import "GraphVC.h"
#import "AboutVC.h"
#import "TestVC.h"
#import "MinuteTVC.h"

@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // load intro screens on first launch
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [self loadMainViews];
    
    // load the intro view if the user's email isn't set
    if (![defaults stringForKey:@"email"]) {
//    if (YES) {
        [self loadIntroViews]; }
    
    // set default for cookie storage
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    // show
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) loadMainViews {
    
    ExerciseVC *exerciseVC = [[ExerciseVC alloc] init];
    GraphVC *graphVC = [[GraphVC alloc] init];
    AboutVC *aboutVC = [[AboutVC alloc] init];
//    TestVC *testVC = [[TestVC alloc] init];
    
    // add tabs
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[exerciseVC, graphVC, aboutVC];
    self.window.rootViewController = tabBarController;
    self.window.backgroundColor = [UIColor whiteColor];

    
    // add plus button
    CGRect frame = [UIScreen mainScreen].bounds;
    CGRect rightFrame = CGRectMake(frame.size.width - 170, 10, 200, 40);
    UIButton *plusButton = [[UIButton alloc] initWithFrame:rightFrame];
    [plusButton setTitle:@"manual entry +" forState:UIControlStateNormal];
    [plusButton setTitleColor:[UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    [plusButton addTarget:self action:@selector(pushMinuteVC) forControlEvents:UIControlEventTouchUpInside];
    [self.window.rootViewController.view addSubview:plusButton];
    
    [self.window makeKeyAndVisible];
}

- (void) loadIntroViews{
    
    IntroPageVC *introPageVC = [[IntroPageVC alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:NULL];
    
    // sneakily make sure the UiPageViewController is called again whenever anything is added to its array of objects
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor clearColor];
    pageControl.currentPageIndicatorTintColor = [UIColor clearColor];

    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:introPageVC];


    [self.window.rootViewController presentViewController:navController animated:YES completion:nil];
}


- (void)pushMinuteVC {
    MinuteTVC *minuteTVC = [[MinuteTVC alloc] init];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:minuteTVC];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    
    [self.window.rootViewController presentViewController:navController animated:YES completion:nil];
}

@end










