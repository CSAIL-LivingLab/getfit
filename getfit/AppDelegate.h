//
//  AppDelegate.h
//  OpenSense Collector
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;

//- (void) setupLocationManager;



@end
