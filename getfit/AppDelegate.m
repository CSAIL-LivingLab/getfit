//
//  AppDelegate.m
//  GetFit
//
//  Created by Albert Carter on 12/01/14.
//  Copyright (c) 2014 MIT CSAIL Living Lab. All rights reserved.
//

#import "AppDelegate.h"
#import "OpenSense.h"
#import "LocationObject.h"

#import "IntroVC.h"

#import "AboutVC.h"
#import "ExerciseVC.h"
#import "GraphVC.h"
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

    
    
    if (![defaults boolForKey:@"loaded_v.1.1"]) {
        [[MinuteStore sharedStore] removeAllMinutes];
        [[OpenSense sharedInstance] deleteAllBatches];
        [defaults setObject:nil forKey:@"email"];
        [defaults setBool:YES forKey:@"loaded_v.1.1"];
        [defaults synchronize];
    }
    
    // load main and then intro view if the user's email isn't set
    // else just load the main views
    if (![defaults stringForKey:@"username"]) {
//    if (YES) {
        // make sure the collector doesn't start right away
        [defaults setObject:[NSDate distantFuture] forKey:@"resumeSensorDate"];
        [defaults setObject:nil forKey:@"email"];
        [defaults setObject:nil forKey:@"username"];
        [defaults setObject:nil forKey:@"password"];
        [defaults setBool:YES forKey:@"postToGetFit"];
        [defaults synchronize];
        [self loadMainViews];
        [self loadIntroViews];
    } else {
        [self loadMainViews];
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
    // add tabs
    UITabBarController *tabBarController = [[UITabBarController alloc] init];
    tabBarController.viewControllers = @[exerciseVC, graphVC, aboutVC];
    self.window.rootViewController = tabBarController;
    self.window.backgroundColor = [UIColor whiteColor];

    
    [self.window makeKeyAndVisible];
}

- (void) loadIntroViews{
    
    IntroVC *introVC = [[IntroVC alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:introVC];
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










