//
//  Location.m
//  GetFit
//
//  Created by Albert Carter on 2/4/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import "LocationObject.h"
#import "OpenSense.h"
#import "Resources.h"


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
        // register for memory warning notifications
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
        [nc addObserver:self selector:@selector(dumpOpenSenseData) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
        
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
    
    // send a notification to the user
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    NSDate *now = [NSDate date];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMM dd, hh:mm a"];
    NSString *currentDate = [df stringFromDate:now];
    localNotification.fireDate = now;
    localNotification.alertBody = [NSString stringWithFormat:@"didUpdateLocation at %@", currentDate];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    
    // start gathering data, and then turn the collector off after 30 seconds
    NSLog(@"\n\n----SIGNIFICANTLOCATIONCHANGE-----\n\n");
    OpenSense *opensense = [OpenSense sharedInstance];
    [opensense startCollector];
    [NSTimer scheduledTimerWithTimeInterval:10 target:[Resources sharedResources] selector:@selector(uploadOpenSenseData) userInfo:nil repeats:NO];
}

- (void) dumpOpenSenseData{
    // called when the object receives a memory warning
    // just dumps the batches
    NSLog(@"didReceiveMemory warning called. LocationObject heard it.");
    [[OpenSense sharedInstance] stopCollector];
    [[OpenSense sharedInstance] deleteAllBatches];
}

@end
