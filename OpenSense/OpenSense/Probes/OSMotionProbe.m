//
//  OSMotionProbe.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/24/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSMotionProbe.h"


@implementation OSMotionProbe{
    CMMotionManager *motionManager;
    
    double updateInterval;
    double sampleFrequency;
    double sampleDuration;
    
    NSTimer *sampleFrequencyTimer;
    NSTimer *sampleDurationTimer;
}

- (id) init
{
    self = [super init];
    if (self) {
        
        // get probe from config.json
        NSDictionary *configDict = [[OSConfiguration currentConfig] motionConfig];
        sampleFrequency = [[configDict objectForKey:@"frequency"] doubleValue]; // seconds between sample
        sampleDuration = [[configDict objectForKey:@"duration"] doubleValue]; // how long a sample takes
        updateInterval = [[configDict objectForKey:@"updateInterval"] doubleValue]; // Hz at which samples are updated.
    }
    
    return self;
}

+ (NSString*)name
{
    return @"Motion";
    return nil;
}

+ (NSString*)identifier
{
    return @"motion";
}

+ (NSString*)description
{
    return @"Collects gyroscope, acceleration, magnometer data from the device";
}

+ (NSTimeInterval)defaultUpdateInterval
{
    return kUpdateIntervalPush;
}

- (void)startProbe
{
    if(sampleFrequency - sampleDuration < 0){
        [NSException raise:@"Your OSMotionProbe frequency/duration are incorrect" format:@"Check to make sure your greater tha is less than your kMotionSampleDuration"];
    }

    
    // Initialize motion manager and queue
    motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval = updateInterval;
    operationQueue = [[NSOperationQueue alloc] init];
    
    // Start generating and sampling data

    [self startSample];  // Spawn new thread to avoid sampleFrequency delay
    sampleFrequencyTimer = [NSTimer scheduledTimerWithTimeInterval:sampleFrequency target:self selector:@selector(startSample) userInfo:nil repeats:YES];

    
    [super startProbe];
}

- (void)stopProbe
{
    // Invalidate and clear timers
    if (sampleFrequencyTimer){
        [sampleFrequencyTimer invalidate];
        sampleFrequencyTimer = nil;
    }
    if (sampleDurationTimer){
        [sampleDurationTimer invalidate];
        sampleDurationTimer = nil;
    }

    
    // Stop receving updates and release objects
    [motionManager stopDeviceMotionUpdates];
        
    motionManager = nil;
    operationQueue = nil;
    
    [super stopProbe];
}

- (NSDictionary *) sendData
{
    if (!lastData){
        return nil;
    }
    
    NSNumber *attitude_roll     = [NSNumber numberWithDouble:lastData.attitude.roll];
    NSNumber *attitude_pitch    = [NSNumber numberWithDouble:lastData.attitude.pitch];
    NSNumber *attitude_yaw      = [NSNumber numberWithDouble:lastData.attitude.yaw];
    
    NSNumber *rotationRate_x    = [NSNumber numberWithDouble:lastData.rotationRate.x];
    NSNumber *rotationRate_y    = [NSNumber numberWithDouble:lastData.rotationRate.y];
    NSNumber *rotationRate_z    = [NSNumber numberWithDouble:lastData.rotationRate.z];
    
    NSNumber *gravity_x         = [NSNumber numberWithDouble:lastData.gravity.x];
    NSNumber *gravity_y         = [NSNumber numberWithDouble:lastData.gravity.y];
    NSNumber *gravity_z         = [NSNumber numberWithDouble:lastData.gravity.z];
    
    NSNumber *userAcceleration_x= [NSNumber numberWithDouble:lastData.userAcceleration.x];
    NSNumber *userAcceleration_y= [NSNumber numberWithDouble:lastData.userAcceleration.x];
    NSNumber *userAcceleration_z= [NSNumber numberWithDouble:lastData.userAcceleration.x];
    
    
    NSDictionary *data = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                                 attitude_roll, @"aR",
                                 attitude_pitch, @"aP",
                                 attitude_yaw, @"aY",
                                 
                                 rotationRate_x, @"rX",
                                 rotationRate_y, @"rY",
                                 rotationRate_z, @"rZ",
                                 
                                 gravity_x, @"gX",
                                 gravity_y, @"gY",
                                 gravity_z, @"gZ",
                                 
                                 userAcceleration_x, @"uaX",
                                 userAcceleration_y, @"uaY",
                                 userAcceleration_z, @"uaZ",
                                 
                                 nil];
    
    return data;
}

# pragma mark - sample start/stop

- (void) startSample
{
    
    [motionManager startDeviceMotionUpdatesToQueue:operationQueue withHandler:^(CMDeviceMotion *motionData, NSError *error) {
        lastData = motionData;
        
        [self saveData];
    }];
    
    // after a period of time stop the motion Manager
    sampleDurationTimer = [NSTimer scheduledTimerWithTimeInterval:sampleDuration target:self selector:@selector(stopSample) userInfo:nil repeats:NO];
    
}

- (void) stopSample
{
    [motionManager stopDeviceMotionUpdates];
}

@end
