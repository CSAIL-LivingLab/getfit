//
//  OSPositioningProbe.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSPositioningProbe.h"

@implementation OSPositioningProbe

+ (NSString*)name
{
    return @"Positioning";
}

+ (NSString*)identifier
{
    return @"positioning";
}

+ (NSString*)description
{
    return @"Monitors significant location changes";
}

+ (NSTimeInterval)defaultUpdateInterval
{
    return kUpdateIntervalPush;
}

- (void)startProbe
{
    locationManager = [[CLLocationManager alloc] init];
    [locationManager setDelegate:self];
    
    int authStatus = [CLLocationManager authorizationStatus];
    
    if (authStatus == kCLAuthorizationStatusNotDetermined && floor(kCFCoreFoundationVersionNumber) > kCFCoreFoundationVersionNumber_iOS_7_1) {
        [locationManager requestAlwaysAuthorization];
    } else {
//        [locationManager startMonitoringSignificantLocationChanges];
        [self startMonitoringLocation];
    }
    
    [super startProbe];
}

- (void)stopProbe
{
//    [locationManager stopMonitoringSignificantLocationChanges];
    [locationManager stopUpdatingLocation];
    locationManager = nil;
    
    [super stopProbe];
}

- (NSDictionary*)sendData
{
    if (!lastLocation)
        return nil;
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 [NSNumber numberWithDouble:lastLocation.coordinate.latitude], @"lat",
                                 [NSNumber numberWithDouble:lastLocation.coordinate.longitude], @"lon",
                                 [NSNumber numberWithDouble:lastLocation.altitude], @"alt",
                                 [NSNumber numberWithDouble:lastLocation.speed], @"spd", // m/s
                                 [NSNumber numberWithDouble:lastLocation.horizontalAccuracy], @"hor_acc",
                                 [NSNumber numberWithDouble:lastLocation.verticalAccuracy], @"vert_acc",
                                 [NSNumber numberWithDouble:lastLocation.course], @"crs", // 0 - 359.9 degrees
                                 nil];
    
    return data;
}

- (void) startMonitoringLocation {
    [locationManager setDesiredAccuracy:kCLLocationAccuracyBestForNavigation];
    [locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    if ([locations count] <= 0)
        return;
    
    // Save location and tell probe to store it
    lastLocation = [locations objectAtIndex:0];
    [self saveData];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    OSLog(@"Could not monitor location: %@", [error localizedDescription]);
}

- (void) locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways) {
//        [manager startMonitoringSignificantLocationChanges];
        [self startMonitoringLocation];
    }
}


















@end
