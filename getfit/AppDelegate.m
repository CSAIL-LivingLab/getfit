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
#import "InfoVC.h"
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
        [defaults setObject:@"arcarter@mit.edu" forKey:@"email"];
        [defaults setObject:@"al_carter" forKey:@"username"];
        [defaults setObject:@"--" forKey:@"password"];
        [defaults synchronize];
        
        [self loadIntroViews]; }
    
    // set default for cookie storage
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    // set up the location manager
    [self setupLocationManager];
    [NSThread sleepForTimeInterval:.5];

    // show
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) loadMainViews {
    
    ExerciseVC *exerciseVC = [[ExerciseVC alloc] init];
    GraphVC *graphVC = [[GraphVC alloc] init];
    InfoVC *aboutVC = [[InfoVC alloc] init];
    TestVC *testVC = [[TestVC alloc] init];
    
    // add tabs
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[testVC, exerciseVC, graphVC, aboutVC];
    self.window.rootViewController = tabBarController;
    self.window.backgroundColor = [UIColor whiteColor];

    
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

- (void) setupLocationManager{
    _locationManager = [[CLLocationManager alloc] init];
    [_locationManager startMonitoringSignificantLocationChanges];
    _locationManager.delegate = self;
}

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *resumeSensorDate = [defaults objectForKey:@"resumeSensorDate"];
    
    // do nothing if it's not time to resume tracking
    if (resumeSensorDate !=nil && [resumeSensorDate compare:[NSDate date]] == NSOrderedDescending) {
        return;
    }
    
    // start gathering data, and then turn the collector off after 30 seconds
    NSLog(@"\n\n----SIGNIFICANTLOCATIONCHANGE-----\n\n");
    OpenSense *opensense = [OpenSense sharedInstance];
    [opensense startCollector];
    [NSTimer scheduledTimerWithTimeInterval:5 target:[OpenSense sharedInstance] selector:@selector(stopCollector) userInfo:nil repeats:NO];
}

@end










