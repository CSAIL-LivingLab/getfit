//
//  Location.m
//  GetFit
//
//  Created by Albert Carter on 2/4/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import "LocationObject.h"
#import "OpenSense.h"


@implementation LocationObject {
    CLLocationManager *locationManager;
}


+ (instancetype) sharedLocationObject {
    static LocationObject *locationObject;
    
    if (!locationObject) {
        locationObject = [[self alloc] initPrivate];
    }
    return locationObject;
}


- (instancetype) initPrivate {
    self = [super init];
    
    if (self) {
       // do some initialization stuff here
    }
    return self;
}

- (void) setupLocationManager{
    locationManager = [[CLLocationManager alloc] init];
    [locationManager startMonitoringSignificantLocationChanges];
    locationManager.delegate = self;
}


- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
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
