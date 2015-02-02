//
//  OpenSense.m
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import "OpenSense.h"
#import "AFNetworking.h"
#import "UIDevice+IdentifierAddition.h"
#import "STKeychain.h"
#import "NSString+MD5Addition.h"
#import "OSLocalStorage.h"
#import "OSConfiguration.h"

#import "OSPositioningProbe.h"
#import "OSDeviceInfoProbe.h"
#import "OSBatteryProbe.h"
#import "OSProximityProbe.h"
#import "OSActivityManagerProbe.h"
#import "OSMotionProbe.h"

@implementation OpenSense {
    NSUserDefaults *defaults;
}

@synthesize isRunning;
@synthesize startTime;

+ (OpenSense*)sharedInstance
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init
{
    self = [super init];
    
    if (self)
    {
        defaults = [NSUserDefaults standardUserDefaults];
    }
    
    return self;
}

- (BOOL)startCollector
{
    // Make sure that the collector process is not already running
    if (isRunning) {
        return NO;
    }
    
    // Update state information
    isRunning = YES;
    startTime = [NSDate date];
    [defaults setBool:YES forKey:@"OSCollecting"];
    
    // Start all probes
    activeProbes = [[NSMutableArray alloc] init];
    for (Class class in [self enabledProbes])
    {
        OSProbe *probe = [[class alloc] init];
        [activeProbes addObject:probe];
        [probe startProbe];
    }
    
    // Start timers
    uploadTimer = [NSTimer scheduledTimerWithTimeInterval:[[[OSConfiguration currentConfig] dataUploadPeriod] doubleValue] target:self selector:@selector(uploadData:) userInfo:nil repeats:YES];
    
    // Turn off config updating for now, as I don't see a reason for it -- ARC 2014-08-19.
    //    configTimer = [NSTimer scheduledTimerWithTimeInterval:[[[OSConfiguration currentConfig] configUpdatePeriod] doubleValue] target:self selector:@selector(refreshConfig:) userInfo:nil repeats:YES];
    
    // For debugging
    //[self uploadData:nil];
    
    return YES;
}

- (void)stopCollector
{
    // Only stop collector process if it is already running
    OSLog(@"OpenSense stopCollector called");
    if (!isRunning) {
        return;
    }
    
    for (OSProbe *probe in activeProbes)
    {
        [probe stopProbe];
    }
    
    // update state information
    activeProbes = nil;
    [defaults setBool:NO forKey:@"OSCollecting"];
    isRunning = NO;
    
    // Stop timers
    [uploadTimer invalidate];
    uploadTimer = nil;
    
    [configTimer invalidate];
    configTimer = nil;
}

- (NSArray*)availableProbes
{
    
    NSMutableArray *availableProbes = [[NSMutableArray alloc]
                                       initWithObjects:
                                       [OSPositioningProbe class],
                                       [OSMotionProbe class],
                                       [OSDeviceInfoProbe class],
                                       [OSBatteryProbe class],
                                       [OSProximityProbe class],
                                       nil];

    // it's best to check for m7 here. additional check is done on probe level.
    if ([CMMotionActivityManager isActivityAvailable] && [CMStepCounter isStepCountingAvailable])
        [availableProbes addObject:[OSActivityManagerProbe class]];
    
    return availableProbes;
}

- (NSArray*)enabledProbes
{
    NSArray *configEnabledProbes = [[OSConfiguration currentConfig] enabledProbes];
    NSMutableArray *enabledProbesMutableList = [[NSMutableArray alloc] init];
    
    for (Class probe in [self availableProbes])
    {
        if ([configEnabledProbes containsObject:[probe identifier]])
        {
            [enabledProbesMutableList addObject:probe];
        }
    }
    
    NSArray *enabledProbesList = [[NSArray alloc] initWithArray:enabledProbesMutableList];
    return enabledProbesList;
}

- (NSString*)probeNameFromIdentifier:(NSString*)probeIdentifier
{
    for (Class probe in [self availableProbes])
    {
        if ([[probe identifier] isEqualToString:probeIdentifier])
        {
            return [probe name];
        }
    }
    
    return nil;
}

- (void)localDataBatches:(void (^)(NSArray *batches))success
{
    [[OSLocalStorage sharedInstance] fetchBatches:success];
}

- (void)localDataBatchesForProbe:(NSString*)probeIdentifier success:(void (^)(NSArray *batches))success
{
    [[OSLocalStorage sharedInstance] fetchBatchesForProbe:probeIdentifier skipCurrent:NO parseJSON:YES success:success];
}

- (void) stopCollectorAndUploadData
{
//    [self stopCollector];
    [self uploadData:nil];
}

- (void)uploadData:(id)sender
{
    OSLog(@"uploadData called");
    
    // Fetch probe data, but if openSense is running, skip the currently used probe file to avoid conflicts. See Thesis p. 37
    BOOL * skipCurrent = [OpenSense sharedInstance].isRunning;
    [[OSLocalStorage sharedInstance] fetchBatchesForProbe:nil skipCurrent:skipCurrent parseJSON:NO success:^(NSArray *batches) {
        
        OSLog(@"Constructing JSON document with %lu batches", (unsigned long)[batches count]);
        
        // Construct JSON document by comma-separating indvidual data batches
        NSString *jsonFile = [[NSString alloc] init];
        for (NSData *lineData in batches) {
            NSString *lineStr = [[NSString alloc] initWithData:lineData encoding:NSUTF8StringEncoding];
            
            if (lineStr) {
                jsonFile = [jsonFile stringByAppendingFormat:@"%@,", lineStr];
            }
        }
        
        // We don't need to upload anything if no valid data was found
        if ([jsonFile length] <= 0) {
            return;
        }
        
        // Remove the last comma
        jsonFile = [jsonFile substringToIndex:[jsonFile length] - 1];
        
        // ...and add array brackets
        jsonFile = [NSString stringWithFormat:@"[%@]", jsonFile];
        
//        OSLog(@"Json File to be sent:\n%@", jsonFile);
        
        // Create hash of document for integrity checking
        NSString *jsonFileHash = [jsonFile stringFromMD5];
        
        AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[OSConfiguration currentConfig].baseUrl];
        
        NSDictionary *params = @{
            @"file_hash": jsonFileHash,
            @"device_id": [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier],
            @"data": jsonFile,
            @"datastore_owner__uuid": [[UIDevice currentDevice] uniqueGlobalDeviceIdentifier],
            @"bearer_token": @"3f4851fd8a"
            
        };
        
        NSMutableURLRequest *request = [httpClient requestWithMethod:@"POST" path:@"upload" parameters:params];

        OSLog(@"%@", params);
        
        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            
            OSLog(@"\n\n\n\n%@\n\n\n\n", JSON);
            
            if ([JSON objectForKey:@"status"] && [[JSON objectForKey:@"status"] isEqualToString:@"ok"]) {
                [self deleteAllBatches];
            } else {
                OSLog(@"Could not upload collected data");
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            OSLog(@"\n\nerror: %@\n", error);
            OSLog(@"\njson: %@\n", JSON);
            OSLog(@"Could not upload collected data");
        }];
        
        [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            OSLog(@"Uploading.. %lld / %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        }];
        
        [operation start];
    }];
}


- (void) fetchAllBatches {
    BOOL * skipCurrent = [OpenSense sharedInstance].isRunning;
    NSMutableString *allJsonData = [NSMutableString stringWithString:@""];
    
    [[OSLocalStorage sharedInstance] fetchBatchesForProbe:nil skipCurrent:skipCurrent parseJSON:NO success:^(NSArray *batches) {
        
        OSLog(@"Constructing JSON document with %lu batches", (unsigned long)[batches count]);
        
        // Construct JSON document by comma-separating indvidual data batches
        NSString *jsonFile = [[NSString alloc] init];
        for (NSData *lineData in batches) {
            NSString *lineStr = [[NSString alloc] initWithData:lineData encoding:NSUTF8StringEncoding];
            
            if (lineStr) {
                jsonFile = [jsonFile stringByAppendingFormat:@"%@,", lineStr];
            }
        }
        
        // We don't need to append anything if no valid data was found
        if ([jsonFile length] <= 0) {
            return;
        }
        
        // Remove the last comma
        jsonFile = [jsonFile substringToIndex:[jsonFile length] - 1];
        
        // ...and add array brackets
        jsonFile = [NSString stringWithFormat:@"[%@]", jsonFile];
        [allJsonData appendString:jsonFile];
        
        [_delegate didFinishFetchingBatches:allJsonData];
    }
     ];
}

- (BOOL) deleteAllBatches {
    BOOL success = [[OSLocalStorage sharedInstance] deleteAllBatches];
    return success;
}

- (void)refreshConfig:(id)sender
{
    [[OSConfiguration currentConfig] refresh];
}

# pragma mark - background methods


@end
