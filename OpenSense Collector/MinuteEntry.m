//
//  MinuteEntry.m
//  GetFit
//
//  Created by Albert Carter on 12/29/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import "MinuteEntry.h"
#import "MinuteStore.h"

@implementation MinuteEntry

- (instancetype) init {
    self = [super init];
    
    if ([super init]) {
        _activity = @"";
        _intensity = @"";
        _duration = 0;
        _endTime = [NSDate date];
    }
    return self;
}

- (instancetype) initEntryWithActivity:(NSString *)activity
                            intensity:(NSString *)intensity
                             duration:(NSInteger)duration
                           andEndTime:(NSDate *)endTime {
    self = [super init];
    
    if (self) {
        _activity = activity;
        _intensity = intensity;
        _duration = duration;
        _endTime = endTime;
    }
    
    return self;
}


- (BOOL) verifyEntry {
    if ([_activity length] + [_intensity length] < 2) {
        return NO;
    }
    
    if (_duration == 0) {
        return NO;
    }

    return YES;
}


@end
