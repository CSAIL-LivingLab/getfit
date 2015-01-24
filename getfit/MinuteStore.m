//
//  MinuteStore.m
//  GetFit
//
//  Created by Albert Carter on 12/29/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#include<unistd.h>
#include<netdb.h>

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
        NSString *path = [self entryArchivePath];
        _privateMinutes = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if (!_privateMinutes) {
            _privateMinutes = [[NSMutableArray alloc] init];
        }
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

- (BOOL) removeMinuteEntryIfPostedToDataHubAndGetFit:(MinuteEntry *) minuteEntry {
    if (minuteEntry.postedToGetFit && minuteEntry.postedToDataHub) {
        [self removeMinuteEntry:minuteEntry];
        return YES;
    }
    return NO;
}

- (void) removeMinuteEntry:(MinuteEntry *)minuteEntry {
    minuteEntry.activity = nil;
    minuteEntry.intensity = nil;
    minuteEntry.endTime = nil;
    minuteEntry.duration = nil;
    [_privateMinutes removeObject:minuteEntry];
}

- (BOOL) postToDataHub {
    
    if (![self isNetworkAvailable:@"datahub.csail.mit.edu"]) {
        [self saveChanges];
        return NO;
    }
    
    NSString *appID = [Secret sharedSecret].DHAppID;
    NSString *appToken = [Secret sharedSecret].DHAppToken;
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    
    // edit the first entry. Delete this if not testing.
//    MinuteEntry *me0 = [_privateMinutes objectAtIndex:0];
//    me0.activity = @"foosball";
//    me0.intensity = @"silly";
    
    
    //format query
    NSMutableString *statement = [[NSMutableString alloc] initWithString:@"insert into getfit.minutes(activity, intensity, duration, endDate, verified) values "];
    int numberOfMinutesToPost = 0;
    for (int i=0; i< [_privateMinutes count]; i++) {
        MinuteEntry *me = [_privateMinutes objectAtIndex:i];
        
        // exclude the minutes that have already been posted to DataHub
        if (me.postedToDataHub) {
            continue;
        }
        
        // this indicates an invalid entry,
        // probably from an earlier version of GetFit
        // it should just be deleted
        if (me.duration == NSIntegerMax || me.duration == 4459342576 || me.activity == nil) {
            [[MinuteStore sharedStore] removeMinuteEntry:me];
            i = i-1;
            continue;
        }
        
        if (me.intensity == nil) {
            me.intensity = @"medium";
        }
 
        
        
        NSInteger *endTimeInt = (NSInteger)roundf([me.endTime timeIntervalSince1970]);
        NSString *verified;
        
        if (me.verified) {
            verified = @"TRUE";
        } else {
            verified = @"FALSE";
        }
        NSString *insertStmt = [NSString stringWithFormat:@"('%@', '%@', %@, to_timestamp(%tu), %@),", me.activity, me.intensity, @(me.duration), endTimeInt, verified];
        
        
        [statement appendString:insertStmt];
        
        if (i == [_privateMinutes count] -1) {
            numberOfMinutesToPost++;
            [statement deleteCharactersInRange:NSMakeRange([statement length]-1, 1)];
            [statement appendString:@";"];
        }
    }
    
    // make sure that we're actually posting _something_ to datahub
    if (numberOfMinutesToPost < 1) {
        return NO;
    }
    
    // connect to server
    datahubDataHubClient *datahub_client = [[Resources sharedResources] createDataHubClient];
    datahubConnectionParams *con_params_app = [[datahubConnectionParams alloc] initWithClient_id:nil seq_id:nil user:nil password:nil app_id:appID app_token:appToken repo_base:username];
    datahubConnection * con_app = [datahub_client open_connection:con_params_app];
    NSLog(@"%@", statement);

    // query
    @try {
        [datahub_client execute_sql:con_app query:statement query_params:nil];
        
        // mark minutes as posted by DataHub, and remove if appropriate
        for (MinuteEntry *me in _privateMinutes){
            me.postedToDataHub = YES;
            [self removeMinuteEntryIfPostedToDataHubAndGetFit:me];
        }
        
        [self saveChanges];
        return YES;
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Upload failed" message:[NSString stringWithFormat:@"GetFit failed to connect to DataHub (%@)",[exception description]] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        NSLog(@"%@", exception);
        return NO;
    }
}

- (BOOL) postToGetFit {
    
    if (![self isNetworkAvailable:@"getfit.mit.edu"]) {
        [self saveChanges];
        return NO;
    }
    
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-DD"];

    // intensity must be all lower case
    // duration must be >= 1
    // spaces for activities work
    for (int i=0; i< [_privateMinutes count]; i++) {
        
        MinuteEntry *me = [_privateMinutes objectAtIndex:i];
        
        // exclude the minutes that have already been posted to DataHub
        if (me.postedToGetFit) {
            continue;
        }
        
        
        NSString *activity;
        NSString *intensity;
        NSString *endDate;
        NSString *duration;
        
        if (me.activity != nil) {
            activity = me.activity;
        } else {
            activity=@"undefined";
        }
        
        if (me.intensity !=nil){
            intensity = me.intensity;
        } else {
            intensity=@"medium";
        }
        
        if (me.endTime != nil) {
            endDate =[ dateFormatter stringFromDate:me.endTime];
        } else {
            endDate = [dateFormatter stringFromDate:[NSDate date]];
        }
        
        duration = [NSString stringWithFormat: @"%ld", (long)me.duration];
        
        // update the activityPickerArr
        [[Resources sharedResources] setActivityAsFirst:activity];
        
        // get the day of the week
        NSInteger *dayIndex = [self indexOfDayInWeekForMinuteEntry:me];
        
        
        // get the form info
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        NSString *form_token = [[defaults objectForKey:@"form_tokens"] objectAtIndex:dayIndex];
        NSString *form_build_id = [[defaults objectForKey:@"form_build_ids"] objectAtIndex:dayIndex];
        NSString *form_id = [[defaults objectForKey:@"form_ids"] objectAtIndex:dayIndex];
        
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
        
        me.postedToGetFit = YES;
        
        [self removeMinuteEntryIfPostedToDataHubAndGetFit:me];
    }
    [self saveChanges];
    return YES;
}

- (NSInteger *) indexOfDayInWeekForMinuteEntry:(MinuteEntry *)me {
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    [weekday setDateFormat: @"EEEE"];
    NSString *weekdayStr = [weekday stringFromDate:me.endTime];
    
    if ([weekdayStr isEqualToString:@"Monday"]) {
        return 0;
    } else if ([weekdayStr isEqualToString:@"Tuesday"]) {
        return 1;
    } else if ([weekdayStr isEqualToString:@"Wednesday"]) {
        return 2;
    } else if ([weekdayStr isEqualToString:@"Thursday"]) {
        return 3;
    } else if ([weekdayStr isEqualToString:@"Friday"]) {
        return 4;
    } else if ([weekdayStr isEqualToString:@"Saturday"]) {
        return 5;
    } else if ([weekdayStr isEqualToString:@"Sunday"]) {
        return 6;
    }
    
     // return sunday for default
     return 6;
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

- (BOOL) checkForValidTokens:(NSDate *)postDate {
    // used to find out if the user needs to reload the webpage
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDate *lastExtractDate = [defaults objectForKey:@"last_token_extract"];
    
    Resources *resources = [Resources sharedResources];
    NSDate *sundayAfterExtract = [resources nextSundayFromDate:lastExtractDate];
    
    if ([postDate compare:sundayAfterExtract] == NSOrderedAscending) {
        return YES;
    }
    
    return NO;
    
}

# pragma mark - persistance

- (BOOL) saveChanges {
    NSString *path = [self entryArchivePath];
    return [NSKeyedArchiver archiveRootObject:self.privateMinutes toFile:path];
}

- (NSString *)entryArchivePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,                                                                       NSUserDomainMask, YES);
    
    // get first one, because ios
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:@"entry.archive"];
}

# pragma mark - network reachability

-(BOOL)isNetworkAvailable:(NSString *)hostname
{
    const char *cHostname = [hostname UTF8String];
    struct hostent *hostinfo;
    hostinfo = gethostbyname (cHostname);
    if (hostinfo == NULL){
        NSLog(@"-> no connection!\n");
        return NO;
    }
    else{
        NSLog(@"-> connection established!\n");
        return YES;
    }
}


@end











