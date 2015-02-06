//
//  Resources.h
//  GetFit
//
//  Created by Albert Carter on 12/31/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//
@class datahubDataHubClient;
@class datahub_accountAccountServiceClient;
#import "OpenSense.h"
#import "OSLocalStorage.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface Resources : NSObject <OpenSenseDelegate>

+ (instancetype) sharedResources;

@property (strong, nonatomic) NSArray * activities;
@property (strong, nonatomic) NSArray * intensities;
@property (strong, nonatomic) NSArray * durations;

- (void) setActivityAsFirst:(NSString *) activity;
- (datahubDataHubClient *) createDataHubClient;
- (datahub_accountAccountServiceClient *) createDataHubAccountClient;
- (void) uploadOpenSenseData;

- (NSDate *) previousMondayForDate:(NSDate *)date;
- (NSDate *) nextSundayFromDate:(NSDate *)date;

@end
