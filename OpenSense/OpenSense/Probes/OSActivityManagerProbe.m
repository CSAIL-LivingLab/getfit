//
//  OSActivityManagerProbe.m
//  OpenSense
//
//  Created by Albert Carter on 8/1/14.
//  Copyright (c) 2014 Mathias Hansen. All rights reserved.
//

#import <CoreMotion/CoreMotion.h>
#import "OSActivityManagerProbe.h"

@implementation OSActivityManagerProbe{
    NSTimer *sampleFrequencyTimer;
    double sampleFrequency;
    NSOperationQueue *activityQueue;
    
}

- (id) init{
    self = [super init];
    
    if (self){
        
        activityQueue = [[NSOperationQueue alloc] init];
        activityQueue.maxConcurrentOperationCount = 2;
        
        // get probe info from config.json
        NSDictionary *configDict = [[OSConfiguration currentConfig] sampleFrequencyForProbe:[[self class] identifier]];
        sampleFrequency = [[configDict objectForKey:@"frequency"] doubleValue]; // seconds between when the probe is started
    }
    
    return self;
}

+ (NSString*)name
{
    return @"Activity manager";
}

+ (NSString *) identifier
{
    return @"activitymanager";
}

+ (NSTimeInterval) defaultUpdateInterval
{
    return kUpdateIntervalPush;
}

- (void) startProbe
{
    // ensure that MotionActivity is supported
    if ([CMMotionActivityManager isActivityAvailable] && [CMStepCounter isStepCountingAvailable]) {

        [super startProbe];
        [self saveData];
        sampleFrequencyTimer = [NSTimer
                               scheduledTimerWithTimeInterval:sampleFrequency target:self selector:@selector(saveData) userInfo:nil repeats:YES];
        
        
    } else {
        nil;
    };
}

- (void) stopProbe
{
    if (sampleFrequencyTimer){
        [sampleFrequencyTimer invalidate];
        sampleFrequencyTimer = nil;
    }
    
    [super stopProbe];
}
#pragma mark - frequency related methods

- (void) saveData
{
    // override superclass, because save data is irrelevent if activity isn't avaialble in device
    if ([CMMotionActivityManager isActivityAvailable] && [CMStepCounter isStepCountingAvailable]){
    [super saveData];
    }
}


- (NSDictionary *) sendData
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastSampleDate = [defaults objectForKey:@"lastActivitySample"];
    NSDate *now = [NSDate date];
    
    //Make sure that the app knows when the last sample was taken
    [defaults setObject:now forKey:@"lastActivitySample"];
    [defaults synchronize];

    
    
    CMMotionActivityManager *cm = [[CMMotionActivityManager alloc] init];
    CMStepCounter *sc = [[CMStepCounter alloc] init];
    
    // declare some variables accessible outside of the block
    __block NSDictionary *point = [NSDictionary alloc];
    __block NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    __block NSMutableArray *arr = [[NSMutableArray alloc] init];
    __block BOOL done = FALSE;
    
    [cm queryActivityStartingFromDate:lastSampleDate toDate:now toQueue:activityQueue withHandler:^(NSArray *activities, NSError *error){
        // for each returned activity
        for(int i=0;i<[activities count];i++) {
            CMMotionActivity *a = [activities objectAtIndex:i];

            // define the start and end dates of the activity in question
            NSDate *startDate = a.startDate;
            NSDate *endDate;
            if (i+1 < [activities count]) {
                endDate = [[activities objectAtIndex:i+1] startDate];
            } else {
                endDate = [NSDate date];
            }
            
            NSString *activityString = @"unkn";
            if (a.running) activityString = @"runn";
            else if (a.walking) activityString = @"walk";
            else if (a.automotive) activityString = @"auto";
            else if (a.stationary) activityString = @"stat";
            else if (a.cycling) activityString = @"cycl";

            
            NSString *confidenceString = @"low";
            if (a.confidence == CMMotionActivityConfidenceMedium) confidenceString = @"med";
            else if (a.confidence == CMMotionActivityConfidenceHigh) confidenceString = @"hig";
//            NSLog(@"\n---Activity: %@", activityString);
//            NSLog(@"Confidence: %@", confidenceString);
            
            __block BOOL actDone = FALSE;
            // find stepCounts for that activity
            [sc queryStepCountStartingFrom:startDate to:endDate toQueue:activityQueue withHandler:^(NSInteger numberOfSteps, NSError *error) {
                
                
                NSNumber *steps = [[NSNumber alloc] initWithInteger:numberOfSteps];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss:SSS"];
                NSString *startStr = [dateFormatter stringFromDate:startDate];
                NSString *endStr = [dateFormatter stringFromDate:endDate];
                
                point = [[NSDictionary alloc ] initWithObjectsAndKeys:
                                       activityString, @"act",
                                       confidenceString, @"conf",
                                       steps, @"step",
                                       startStr, @"start",
                                       startStr, @"end",
                                       nil];
                
                NSString *activityStr = point[@"act"];
                NSString *confidenceStr = point[@"conf"];
                NSString *stepStr = [point[@"step"] stringValue];

                
                NSLog(@"\npoint activity: %@, confidence: %@, steps: %@, start: %@, end %@", activityStr, confidenceStr, stepStr, startStr, endStr);
                
                [arr addObject:point];
                actDone = TRUE;
            }];
            while (!actDone);

            [data setObject:arr forKey:@"activityLog"];
        }
        done = TRUE;
        

        
    }];

    while(! done);
    
    return data;
}



@end
