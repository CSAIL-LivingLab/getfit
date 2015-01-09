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
#import "Resources.h"
#import "datahub.h"


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
    NSString *appID = [Secret sharedSecret].DHAppID;
    NSString *appToken = [Secret sharedSecret].DHAppToken;
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    
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
             
    // connect to server
    datahubDataHubClient *datahub_client = [[Resources sharedResources] createDataHubClient];
    datahubConnectionParams *con_params_app = [[datahubConnectionParams alloc] initWithClient_id:nil seq_id:nil user:nil password:nil app_id:appID app_token:appToken repo_base:username];
    datahubConnection * con_app = [datahub_client open_connection:con_params_app];
    
    // query
    @try {
        datahubResultSet *result_set = [datahub_client execute_sql:con_app query:statement query_params:nil];
        NSLog(@"result_set: %@", result_set);
        // minutes are posted to datahub before getfit, so do not remove the objects here
//        [_privateMinutes removeAllObjects];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}

- (void) postToGetFit {
    
    NSHTTPCookie *cookie;
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (cookie in [cookieJar cookies]) {
        NSLog(@"\n\n%@\n", cookie);
        NSLog(@"----\n");
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-DD"];
    
    for (int i=0; i< [_privateMinutes count]; i++) {
        MinuteEntry *me = [_privateMinutes objectAtIndex:i];
        
        NSString *endDate = [dateFormatter stringFromDate:me.endTime];
        NSString *duration = [NSString stringWithFormat: @"%ld", (long)me.duration];
        
        // get the form info
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString *form_token = [defaults objectForKey:@"form_token"];
        NSString *form_build_id = [defaults objectForKey:@"form_build_id"];
        NSString *form_id = [defaults objectForKey:@"form_id"];
        
        // format the data
        NSString *post = [NSString stringWithFormat:@"&form_token=%@&form_build_id=%@&form_id=%@&activity=%@&intensity=%@&date=%@&duration=%@", form_token, form_build_id, form_id, me.activity, me.intensity, endDate, duration];
        post = [post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        
        // create request and send
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:@"https://getfit-d7-dev.mit.edu/system/ajax"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
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
