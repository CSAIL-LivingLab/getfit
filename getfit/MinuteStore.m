//
//  MinuteStore.m
//  GetFit
//
//  Created by Albert Carter on 12/29/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import "MinuteStore.h"
#import "MinuteEntry.h"

// datahub
#import "datahub.h"
#import <THTTPClient.h>
#import <TBinaryProtocol.h>



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

- (void) postToDataHub {
    
    // edit the first entry. Delete this if not testing.
//    MinuteEntry *me0 = [_privateMinutes objectAtIndex:0];
//    me0.activity = @"foosball";
//    me0.intensity = @"silly";
    
    
    
    //format query
    NSMutableString *statement = [[NSMutableString alloc] initWithString:@"insert into getfit.minutes(activity, intensity, duration, endDate) values "];

    for (int i=0; i< [_privateMinutes count]; i++) {
        MinuteEntry *me = [_privateMinutes objectAtIndex:i];
        NSInteger *endTimeInt = (NSInteger)roundf([me.endTime timeIntervalSince1970]);
        NSString *insertStmt = [NSString stringWithFormat:@"('%@', '%@', %@, to_timestamp(%tu)),", me.activity, me.intensity, @(me.duration), endTimeInt];
        
        [statement appendString:insertStmt];
        
        if (i == [_privateMinutes count] -1) {
            [statement deleteCharactersInRange:NSMakeRange([statement length]-1, 1)];
            [statement appendString:@";"];
        }
    }
             
    // connect to server and query
    NSURL * url = [NSURL URLWithString:@"http://datahub.csail.mit.edu/service"];
    THTTPClient *transport = [[THTTPClient alloc] initWithURL:url];
    TBinaryProtocol *protocol = [[TBinaryProtocol alloc]
                                 initWithTransport:transport
                                 strictRead:YES
                                 strictWrite:YES];
    datahubDataHubClient * client = [[datahubDataHubClient alloc] initWithProtocol:protocol];
    datahubConnectionParams *conparams = [[datahubConnectionParams alloc] initWithClient_id:@"foo" seq_id:nil user:@"al_carter" password:@"Gh6$U2!Y" repo_base:nil];
    datahubConnection *connection = [client open_connection:conparams];
    datahubResultSet *result =  [client execute_sql:connection query:statement query_params:nil];

    NSLog(@"%@", result);
    
    [_privateMinutes removeAllObjects];
}

- (void) postToGetFit {
    NSLog(@"post to GetFit not yet implemented");
}




@end
