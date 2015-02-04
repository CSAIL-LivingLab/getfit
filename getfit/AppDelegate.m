//
//  AppDelegate.m
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "AppDelegate.h"
#import "OpenSense.h"
#import "LocationObject.h"

#import "IntroVC.h"

#import "AboutVC.h"
#import "ExerciseVC.h"
#import "GraphVC.h"
#import "MinuteTVC.h"
#import "TestVC.h"

#import "MinuteStore.h"


@implementation AppDelegate {
    NSUserDefaults *defaults;
    LocationObject *locationObj;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    // load intro screens on first launch
    defaults = [NSUserDefaults standardUserDefaults];
    locationObj = [LocationObject sharedLocationObject];
    [self loadMainViews];
    
    // load the intro view if the user's email isn't set
    if (![defaults stringForKey:@"email"]) {
//    if (YES) {
        // make sure the collector doesn't start right away
        [defaults setObject:[NSDate distantFuture] forKey:@"resumeSensorDate"];
        [defaults setObject:nil forKey:@"email"];
        [defaults setObject:nil forKey:@"username"];
        [defaults setObject:nil forKey:@"password"];
        [defaults setBool:YES forKey:@"postToGetFit"];
        [defaults synchronize];
        
        [self loadIntroViews];
    }
    
    if (![defaults boolForKey:@"loaded_v.90"]) {
        [[MinuteStore sharedStore] removeAllMinutes];
        [defaults setBool:YES forKey:@"loaded_v.90"];
        [defaults synchronize];
    }
    
    // set default for cookie storage
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    
    // set up the location manager
    // don't do this on the first load, because on the 5s,
    // the "allow location tracking"
    // alert will then be the first thing the user will see.
    if ([defaults stringForKey:@"email"]) {
        [locationObj setupLocationManager];
        [NSThread sleepForTimeInterval:.5];

    }
    
    
    // show
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) loadMainViews {
    
    ExerciseVC *exerciseVC = [[ExerciseVC alloc] init];
    GraphVC *graphVC = [[GraphVC alloc] init];
    AboutVC *aboutVC = [[AboutVC alloc] init];
    TestVC *testVC = [[TestVC alloc] init];
    
    // add tabs
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[testVC, exerciseVC, graphVC, aboutVC];
    self.window.rootViewController = tabBarController;
    self.window.backgroundColor = [UIColor whiteColor];

    
    [self.window makeKeyAndVisible];
}

- (void) loadIntroViews{
    
    IntroVC *introVC = [[IntroVC alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:introVC];
    [self.window.rootViewController presentViewController:navController animated:YES completion:nil];
}


- (void)pushMinuteVC {
    MinuteTVC *minuteTVC = [[MinuteTVC alloc] init];
    
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:minuteTVC];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;

    
    [self.window.rootViewController presentViewController:navController animated:YES completion:nil];
}

// do this to resume significant location tracking after user re-opens the app, after they've gone through the introduction screens
- (void) applicationDidBecomeActive:(UIApplication *)application {
    if ([defaults stringForKey:@"email"]) {
        [locationObj setupLocationManager];
        [NSThread sleepForTimeInterval:.5];
    }
}




@end










