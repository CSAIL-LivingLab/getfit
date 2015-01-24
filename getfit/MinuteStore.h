//
//  MinuteStore.h
//  GetFit
//
//  Created by Albert Carter on 12/29/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MinuteEntry;

@interface MinuteStore : NSObject

+ (instancetype) sharedStore;

- (MinuteEntry *) createMinuteEntryWithActivity:(NSString *) activity
                          intensity:(NSString *)intensity
                           duration:(NSInteger)duration
                         andEndTime:(NSDate *)endTime;

- (void) addMinuteEntry: (MinuteEntry *) minuteEntry;
- (void) removeAllMinuteEntriesIfPostedToDataHubAndGetFit;
- (BOOL) removeMinuteEntryIfPostedToDataHubAndGetFit:(MinuteEntry *)minuteEntry;
- (void) removeMinuteEntry:(MinuteEntry *)minuteEntry;
- (void) removeAllMinutes;

- (BOOL) postToGetFit;
- (BOOL) postToDataHub;
- (BOOL) checkForValidCookies;
- (BOOL) checkForValidTokens:(NSDate *) postDate;

- (BOOL) isNetworkAvailable:(NSString *)hostname;


- (BOOL) saveChanges;


@end
