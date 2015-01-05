//
//  MinuteStore.m
//  GetFit
//
//  Created by Albert Carter on 12/29/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import "MinuteStore.h"
#import "MinuteEntry.h"

@interface MinuteStore()

@property (nonatomic) NSMutableArray *privateMinutes;

@end

@implementation MinuteStore

+ (instancetype) sharedStore {
    static MinuteStore *sharedStore;
    
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    return sharedStore;
}

- (instancetype) initPrivate {
    self = [super init];
    
    if (self) {
        _privateMinutes = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (instancetype) init {
    [NSException raise:@"Singleton"
                format:@"Use +[MinuteStore sharedStore]"];
    return nil;
}

# pragma mark - manipulating privateMinutes array;

- (MinuteEntry *) createMinuteEntryWithActivity:(NSString *)activity
                             intensity:(NSString *)intensity
                              duration:(NSInteger)duration
                            andEndTime:(NSDate *)endTime {

    MinuteEntry *minuteEntry = [[MinuteEntry alloc] initEntryWithActivity:activity intensity:intensity duration:duration andEndTime:endTime];
    
    [_privateMinutes addObject:minuteEntry];
    return minuteEntry;
}

- (void) addMinuteEntry:(MinuteEntry *)minuteEntry {
    [_privateMinutes addObject:minuteEntry];
}

- (void) removeMinuteEntry:(MinuteEntry *)minuteEntry {
    [_privateMinutes removeObject:minuteEntry];
}




@end
