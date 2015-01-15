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
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-DD"];
    
    // intensity must be all lower case
    // duration must be >= 1
    // spaces for activities work
    for (int i=0; i< [_privateMinutes count]; i++) {
        MinuteEntry *me = [_privateMinutes objectAtIndex:i];
        
        NSString *activity = me.activity;
        NSString *intensity = me.intensity;
        NSString *endDate = [dateFormatter stringFromDate:me.endTime];
        NSString *duration = [NSString stringWithFormat: @"%ld", (long)me.duration];
        
        // default to a duration of 1, to make sure _something_ gets posted
        if ([duration isEqualToString:@"0"]) {
            duration = @"1";
        }
        
        // update the activityPickerArr
        [[Resources sharedResources] setActivityAsFirst:activity];
        
        // get the form info
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString *form_token = [defaults objectForKey:@"form_token"];
        NSString *form_build_id = [defaults objectForKey:@"form_build_id"];
        NSString *form_id = [defaults objectForKey:@"form_id"];
        
        // gather the cookies
        NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        NSArray * cookies  = [cookieJar cookies];
        NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
  
        // format the post body
        NSString *post = [NSString stringWithFormat:@"&form_token=%@&form_build_id=%@&form_id=%@&activity=%@&intensity=%@&date=%@&duration=%@", form_token, form_build_id, form_id, activity, intensity, endDate, duration];
        post = [post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        
        // format the request
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:@"https://getfit-d7-dev.mit.edu/system/ajax"]];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setAllHTTPHeaderFields:headers];
        [request setHTTPBody:postData];
        
//        NSURLResponse *response;
//        NSError *error;
        
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:nil];
        
//        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    }
    
    [_privateMinutes removeAllObjects];
    
}

- (BOOL) checkForValidCookies {
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray * cookies  = [cookieJar cookies];
    NSHTTPCookie *cookie;
    
    BOOL drupalCookie = NO;
    BOOL shibCookie = NO;
    
    for (int i = 0; i< [cookies count]; i++) {
        cookie = [cookies objectAtIndex:i];
//          NSLog(@"\n\nCOOKIE:  %@", cookie.name);
        
        if ([cookie.name rangeOfString:@"SSESS"].location != NSNotFound && [[NSDate date] compare:cookie.expiresDate] == NSOrderedAscending) {
            drupalCookie = YES;
        } else if ([cookie.name rangeOfString:@"_shibsession"].location != NSNotFound) {
            shibCookie = YES;
        }
    }
    
    return shibCookie && drupalCookie;
}




@end











