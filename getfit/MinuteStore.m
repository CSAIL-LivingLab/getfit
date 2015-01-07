//
//  MinuteStore.m
//  GetFit
//
//  Created by Albert Carter on 12/29/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import "MinuteStore.h"
#import "MinuteEntry.h"
#import "Secret.h"

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
    Secret *secret = [Secret sharedSecret];
    
    
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
    datahubConnectionParams *conparams = [[datahubConnectionParams alloc] initWithClient_id:@"foo" seq_id:nil user:secret.DHSuperUser password:secret.DHSuperUserPassword repo_base:nil];
    datahubConnection *connection = [client open_connection:conparams];
    datahubResultSet *result =  [client execute_sql:connection query:statement query_params:nil];

    NSLog(@"%@", result);
    
    [_privateMinutes removeAllObjects];
}

- (void) postToGetFit {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-DD"];
    
    for (int i=0; i< [_privateMinutes count]; i++) {
        MinuteEntry *me = [_privateMinutes objectAtIndex:i];
        me.activity = @"snuggling";
        me.intensity = @"HIGH";
        
        
        NSString *endDate = [dateFormatter stringFromDate:me.endTime];
        NSString *duration = [NSString stringWithFormat: @"%ld", (long)me.duration];
        
        // get the form info
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString *form_token = [defaults objectForKey:@"form_token"];
        NSString *form_build_id = [defaults objectForKey:@"form_build_id"];
        NSString *form_id = [defaults objectForKey:@"form_id"];
        
        // format the data
        NSString *post = [NSString stringWithFormat:@"&form_token=%@&form_build_id=%@&form_id=%@&activity=%@&intensity=%@&date=%@&duration=%@", form_token, form_build_id, form_id, me.activity, me.intensity, endDate, duration];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        
        // create request and send
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:@"https://getfit-d7-dev.mit.edu/system/ajax"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
        [request setHTTPBody:postData];
        NSURLConnection *conn = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        
        
        NSLog(@"%@", [request allHTTPHeaderFields]);
        
        if(conn) {
            NSLog(@"Connection Successful");
        } else {
            NSLog(@"Connection could not be made");
        }

    }
    
    [_privateMinutes removeAllObjects];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data {
    NSLog(@"connection didReceiveData");
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"connection did finish loading");
}




@end
