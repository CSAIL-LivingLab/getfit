//
//  OpenSense.h
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSProbe.h"

#define kOpenSenseBatchSavedNotification @"kOpenSenseBatchSavedNotification"

@protocol OpenSenseDelegate <NSObject>

- (void) didFinishFetchingBatches:(NSString *)batches;

@end

@interface OpenSense : NSObject {
    NSMutableArray *activeProbes;
    BOOL registrationInProgress;
    NSTimer *uploadTimer;
    NSTimer *configTimer;
}

@property (assign, readonly) BOOL isRunning;
@property (strong, readonly) NSDate *startTime;
@property (strong, atomic) NSObject<OpenSenseDelegate> *delegate;

+ (OpenSense*)sharedInstance;
- (BOOL)startCollector;
- (void)stopCollector;
- (NSArray*)availableProbes;
- (NSArray*)enabledProbes;
- (NSString*)probeNameFromIdentifier:(NSString*)probeIdentifier;
- (void)localDataBatches:(void (^)(NSArray *batches))success;
- (void)localDataBatchesForProbe:(NSString*)probeIdentifier success:(void (^)(NSArray *batches))success;

- (void) stopCollectorAndUploadData;

- (void) fetchAllBatches;
- (void) deleteAllBatches;

@end
