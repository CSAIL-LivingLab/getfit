//
//  Resources.m
//  GetFit
//
//  Created by Albert Carter on 12/31/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import "Resources.h"

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
    
    activities = [[NSArray alloc] initWithObjects:@"Aerobics", @"American football", @"Badminton", @"Ballet", @"Bandy", @"Baseball", @"Basketball", @"Beach Volleyball", @"Body Pump", @"Bowling", @"Boxing", @"Circuit Training", @"Cleaning", @"Climbing", @"Cricket", @"Cross country skiing", @"Curling", @"Cycling", @"Dancing", @"Disk Ultimate", @"Downhill skiing", @"Eliptical Training", @"Fencing", @"Floorball", @"Golfing", @"Gym Training", @"Handball", @"Hockey", @"Indoor Cycling", @"Kayaking", @"Kettlebell", @"Kite Surfing", @"Lacrosse", @"Marshall Arts", @"Paddling", @"Paintball", @"Parkour", @"Petanque", @"Pilates", @"Polo", @"Raquetball", @"Riding", @"Roller Blading", @"Roller Skiing", @"Roller Skating", @"Rowing", @"Rugby", @"Running", @"Running on Treadmill", @"Skuba Diving", @"Skateboarding", @"Snowboarding", @"Snow Shoeing", @"Soccer", @"Spinning", @"Squash", @"Stair Climbing", @"Stretching", @"Surfing", @"Swimming", @"Table Tennis", @"Tennis", @"Volleyball", @"Walking", @"Walking on Treadmill", @"Water Polo", @"Weight Training", @"Wheelchair", @"Wind Surfing", @"Wrestling", @"Yoga", @"Zumba", nil];
    
    intensities = [[NSArray alloc] initWithObjects:@"high", @"medium", @"low", nil];
    
    durations = [[NSArray alloc] initWithObjects:@"5 min", @"10 min", @"15 min", @"20 min", @"25 min", @"30 min", @"35 min", @"40 min", @"45 min", @"50 min", @"55 min", @"1 hr  0 min", @"1 hr  5 min", @"1 hr 10 min", @"1 hr 15 min", @"1 hr 20 min", @"1 hr 25 min", @"1 hr 30 min", @"1 hr 35 min", @"1 hr 40 min", @"1 hr 45 min", @"1 hr 50 min", @"1 hr 55 min", @"2 hr  0 min", @"2 hr 15 min", @"2 hr 30 min", @"2 hr 45 min", @"3 hr  0 min", @"3 hr 15 min", @"3 hr 30 min", @"3 hr 45 min", @"4 hr  0 min", @"4 hr 15 min", @"4 hr 30 min", @"4 hr 45 min", @"5 hr  0 min",nil];
    
    return self;
}

- (instancetype) init {
    [NSException raise:@"Singleton"
                format:@"Use +[Resources sharedResources]"];
    return nil;
}

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



@end
