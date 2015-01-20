//
//  Resources.m
//  GetFit
//
//  Created by Albert Carter on 12/31/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//


#import "Resources.h"
#import "Secret.h"

// datahub
#import "datahub.h"
#import "account.h"
#import <THTTPClient.h>
#import <TBinaryProtocol.h>

@implementation Resources
@synthesize activities, intensities, durations;
// this file exists to store the UIPicker options. The only reason it exists is because I haven't had time to refactor the MinuteTVC and ExerciseVC to make the UIPickerViewDataSources orthagonal


+ (instancetype) sharedResources {
    static Resources *sharedResources;
    
    if (!sharedResources) {
        sharedResources = [[self alloc] initPrivate];
    }
    return sharedResources;
}

- (instancetype) initPrivate {
    self = [super init];
    
    NSArray * tempActivities = [[NSArray alloc] initWithObjects:@"Aerobics", @"American Football", @"Badminton", @"Ballet", @"Bandy", @"Baseball", @"Basketball", @"Beach Volleyball", @"Body Pump", @"Bowling", @"Boxing", @"Circuit Training", @"Cleaning", @"Climbing", @"Cricket", @"Cross country skiing", @"Curling", @"Cycling", @"Dancing", @"Disk Ultimate", @"Downhill Skiing", @"Eliptical Training", @"Fencing", @"Floorball", @"Golfing", @"Gym Training", @"Handball", @"Hockey", @"Indoor Cycling", @"Kayaking", @"Kettlebell", @"Kite Surfing", @"Lacrosse", @"Marshall Arts", @"Paddling", @"Paintball", @"Parkour", @"Petanque", @"Pilates", @"Polo", @"Raquetball", @"Riding", @"Roller Blading", @"Roller Skiing", @"Roller Skating", @"Rowing", @"Rugby", @"Running", @"Running on Treadmill", @"Scuba Diving", @"Skateboarding", @"Snowboarding", @"Snow Shoeing", @"Soccer", @"Spinning", @"Squash", @"Stair Climbing", @"Stretching", @"Surfing", @"Swimming", @"Table Tennis", @"Tennis", @"Volleyball", @"Walking", @"Walking on Treadmill", @"Water Polo", @"Weight Training", @"Wheelchair", @"Wind Surfing", @"Wrestling", @"Yoga", @"Zumba", nil];
    
    // load the user activity list
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (![defaults boolForKey:@"activitiesSet"]) {
        [defaults setObject:tempActivities forKey:@"activities"];
        [defaults setBool:YES forKey:@"activitiesSet"];
        [defaults synchronize];
        
        activities = tempActivities;
    } else {
        activities = [defaults objectForKey:@"activities"];
    }
      
    intensities = [[NSArray alloc] initWithObjects:@"High", @"Medium", @"Low", nil];
    
    durations = [[NSArray alloc] initWithObjects:@"5 min", @"10 min", @"15 min", @"20 min", @"25 min", @"30 min", @"35 min", @"40 min", @"45 min", @"50 min", @"55 min", @"1 hr  0 min", @"1 hr  5 min", @"1 hr 10 min", @"1 hr 15 min", @"1 hr 20 min", @"1 hr 25 min", @"1 hr 30 min", @"1 hr 35 min", @"1 hr 40 min", @"1 hr 45 min", @"1 hr 50 min", @"1 hr 55 min", @"2 hr  0 min", @"2 hr 15 min", @"2 hr 30 min", @"2 hr 45 min", @"3 hr  0 min", @"3 hr 15 min", @"3 hr 30 min", @"3 hr 45 min", @"4 hr  0 min", @"4 hr 15 min", @"4 hr 30 min", @"4 hr 45 min", @"5 hr  0 min",nil];
    
    return self;
}

- (instancetype) init {
    [NSException raise:@"Singleton"
                format:@"Use +[Resources sharedResources]"];
    return nil;
}

- (void) setActivityAsFirst:(NSString *)activity {
    
    // insert at the front of the activities array
    NSMutableArray *tempActivities = [NSMutableArray arrayWithArray:activities];
    [tempActivities removeObject:activity];
    [tempActivities insertObject:activity atIndex:0];
    activities = [tempActivities copy];
    
    // synchronize the defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:activities forKey:@"activities"];
    [defaults synchronize];
    
}

# pragma mark - DataHub

- (datahubDataHubClient *) createDataHubClient {
    NSURL *datahub_url = [[NSURL alloc] initWithString:@"https://datahub.csail.mit.edu/service"];
    THTTPClient *datahub_transport = [[THTTPClient alloc] initWithURL:datahub_url];
    TBinaryProtocol *datahub_protocol = [[TBinaryProtocol alloc] initWithTransport:datahub_transport];
    datahubDataHubClient *datahub_client = [[datahubDataHubClient alloc] initWithProtocol:datahub_protocol];
    
    return datahub_client;
}

- (datahub_accountAccountServiceClient *) createDataHubAccountClient {
    NSURL *account_url = [[NSURL alloc] initWithString:@"https://datahub.csail.mit.edu/service/account"];
    THTTPClient *account_transport = [[THTTPClient alloc] initWithURL:account_url];
    TBinaryProtocol *account_protocol = [[TBinaryProtocol alloc] initWithTransport:account_transport];
    datahub_accountAccountServiceClient *account_client = [[datahub_accountAccountServiceClient alloc] initWithProtocol:account_protocol];
    
    return account_client;
}



#pragma mark - OpenSense and OpenSenseDelegate

- (void) uploadOpenSenseData {
    [OpenSense sharedInstance].delegate = self;
    [[OpenSense sharedInstance] stopCollector];
    [[OpenSense sharedInstance] fetchAllBatches];
}

- (void) didFinishFetchingBatches:(NSString *)batches {
    NSString *appID = [Secret sharedSecret].DHAppID;
    NSString *appToken = [Secret sharedSecret].DHAppToken;
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    
    @try {
        
        datahubDataHubClient *datahub_client = [self createDataHubClient];
        datahubConnectionParams *con_params_app = [[datahubConnectionParams alloc] initWithClient_id:nil seq_id:nil user:nil password:nil app_id:appID app_token:appToken repo_base:username];
        datahubConnection * con_app = [datahub_client open_connection:con_params_app];
        
        NSMutableString *statement = [[NSMutableString alloc] initWithString:@"insert into getfit.opensense(data) values ('"];
        
        batches = [[NSString stringWithFormat:@"%@", batches] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        [statement appendString:batches];
        [statement appendString:@"');"];
    
        [datahub_client execute_sql:con_app query:statement query_params:nil];
        [[OpenSense sharedInstance] deleteAllBatches];

    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}

# pragma mark - date utilities
// subclassing NSCalendar isn't easily possible

-(NSDate *)previousSundayForDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    static NSUInteger SUNDAY = 1;

    NSDate *startOfWeek;
    [calendar rangeOfUnit:NSWeekCalendarUnit
            startDate:&startOfWeek
             interval:NULL
              forDate:date];

    if(calendar.firstWeekday == SUNDAY){

        NSDate *beginningOfDate;
        [calendar rangeOfUnit:NSDayCalendarUnit
                startDate:&beginningOfDate
                 interval:NULL forDate:date];
        if ([startOfWeek isEqualToDate:beginningOfDate]) {
            startOfWeek = [calendar dateByAddingComponents:(
                                                        {
                                                            NSDateComponents *comps = [[NSDateComponents alloc] init];
                                                            comps.day = -7;
                                                            comps;
                                                        })
                                                toDate:startOfWeek
                                               options:0];
        }
        return startOfWeek;
    }
    return nil;
}

- (NSDate *) nextSundayFromDate:(NSDate *)date {
    NSDate *previousSunday = [self previousSundayForDate:date];
    NSDate *nextSunday = [previousSunday dateByAddingTimeInterval:60*60*24*7];
    return nextSunday;
}



@end
