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
        _postedToGetFit = NO;
        _postedToDataHub = NO;
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
        _postedToGetFit = NO;
        _postedToDataHub = NO;
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


# pragma mark - NSUserDefaults encoding decoding

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_activity forKey:@"activity"];
    [aCoder encodeObject:_intensity forKey:@"intensity"];
    [aCoder encodeObject:_endTime forKey:@"endTime"];
    
    [aCoder encodeInteger:_duration forKey:@"duration"];
    [aCoder encodeBool:_postedToGetFit forKey:@"postedToGetFit"];
    [aCoder encodeBool:_postedToDataHub forKey:@"postedToDataHub"];
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _activity = [aDecoder decodeObjectForKey:@"activity"];
        _intensity = [aDecoder decodeObjectForKey:@"intensity"];
        _endTime = [aDecoder decodeObjectForKey:@"endTime"];
        
        _duration = [aDecoder decodeIntegerForKey:@"duration"];
        _postedToGetFit = [aDecoder decodeIntegerForKey:@"postedToGetFit"];
        _postedToDataHub = [aDecoder decodeIntegerForKey:@"postedToDataHub"];
    }
    return self;
}


@end
