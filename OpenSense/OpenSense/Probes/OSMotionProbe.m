//
//  OSMotionProbe.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/24/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OSMotionProbe.h"

// kMotionUpdateInterval originally 0.1

#define kMotionUpdateInterval (double) 0.5  // originally 1/50 50Hz
#define kMotionSampleFrequency (double) 30.0 // seconds between samples
#define kMotionSampleDuration (double) 5.0   // probes record data for this many seconds

@implementation OSMotionProbe

+ (NSString*)name
{
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return nil;
}

+ (NSString*)identifier
{
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return nil;
}

+ (NSString*)description
{
    NSAssert(NO, @"This is an abstract method and should be overridden");
    return nil;
}

+ (NSTimeInterval)defaultUpdateInterval
{
    return kUpdateIntervalPush;
}

- (void)startProbe
{
    if(kMotionSampleFrequency - kMotionSampleDuration < 0){
        [NSException raise:@"Your OSMotionProbe frequency/duration are incorrect" format:@"Check to make sure your greater tha is less than your kMotionSampleDuration"];
    }

    
    // Initialize motion manager and queue
    motionManager = [[CMMotionManager alloc] init];
    motionManager.deviceMotionUpdateInterval = kMotionUpdateInterval;
    motionManager.accelerometerUpdateInterval = kMotionUpdateInterval;
    motionManager.magnetometerUpdateInterval = kMotionUpdateInterval;
    motionManager.gyroUpdateInterval = kMotionUpdateInterval;
    operationQueue = [[NSOperationQueue alloc] init];
    
    // Start generating and sampling data

    [self startSample];  // Span new thread to avoid sampleFrequency delay
    NSTimeInterval sampleFrequency = [self sampleFrequency];
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

# pragma mark - sample start/stop

- (void) startSample
{
    
    // after a period of time stop the motion Manager
    NSTimeInterval sampleDuration = [self sampleDuration];
    sampleDurationTimer = [NSTimer scheduledTimerWithTimeInterval:sampleDuration target:self selector:@selector(stopSample) userInfo:nil repeats:NO];
    
}

- (void) stopSample
{
//    NSAssert(NO, @"This is an abstract method and should be overridden");
    [motionManager stopDeviceMotionUpdates];
}

- (NSTimeInterval) sampleFrequency
{
    return kMotionSampleFrequency;
}

- (NSTimeInterval) sampleDuration
{
    return kMotionSampleDuration;
}


@end
