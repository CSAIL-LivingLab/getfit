//
//  AppDelegate.h
//  GetFit
//
//  Created by Albert Carter on 12/01/14.
//  Copyright (c) 2014 MIT CSAIL Living Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface AppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) CLLocationManager *locationManager;

//- (void) setupLocationManager;



@end
