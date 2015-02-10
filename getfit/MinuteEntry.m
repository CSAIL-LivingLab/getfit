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
        _verified = YES;
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
        _verified = YES;
    }
    
    return self;
}


- (BOOL) verifyEntry {
    if (_activity == nil || [_activity isEqualToString:@""]) {
        return NO;
    }
    
    // don't verify intensity. It is set in postToGetFit
//    if (_intensity == nil || [_intensity isEqualToString:@""]) {
//        return NO;
//    }
    
    if (_duration == 0 || _duration > 1440) {
        return NO;
    }

    return YES;
}

- (void) setIntensity:(NSString *)intensity {
    _intensity = [intensity lowercaseString];
}


# pragma mark - NSUserDefaults encoding decoding

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_activity forKey:@"activity"];
    [aCoder encodeObject:_intensity forKey:@"intensity"];
    [aCoder encodeObject:_endTime forKey:@"endTime"];
    
    [aCoder encodeInteger:_duration forKey:@"duration"];
    [aCoder encodeBool:_postedToGetFit forKey:@"postedToGetFit"];
    [aCoder encodeBool:_postedToDataHub forKey:@"postedToDataHub"];
    [aCoder encodeBool:_verified forKey:@"verified"];
}

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        NSLog(@"DECODED ACTIVITY: %@", [aDecoder decodeObjectForKey:@"activity"]);
        NSLog(@"decoded intensity: %@", [aDecoder decodeObjectForKey:@"intensity"]);
        self.activity = [aDecoder decodeObjectForKey:@"activity"];
        self.intensity = [aDecoder decodeObjectForKey:@"intensity"];
        self.endTime = [aDecoder decodeObjectForKey:@"endTime"];
        
        self.duration = [aDecoder decodeIntegerForKey:@"duration"];
        self.postedToGetFit = [aDecoder decodeBoolForKey:@"postedToGetFit"];
        self.postedToDataHub = [aDecoder decodeBoolForKey:@"postedToDataHub"];
        self.verified = [aDecoder decodeBoolForKey:@"verified"];
    }
    return self;
}


@end
