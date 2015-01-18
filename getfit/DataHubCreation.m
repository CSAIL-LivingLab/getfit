//
//  DataHubCreation.m
//  GetFit
//
//  Created by Albert Carter on 1/18/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import "DataHubCreation.h"
#import "account.h"
#import "datahub.h"
#import "Secret.h"
#import "Resources.h"

@implementation DataHubCreation
//@synthesize username, password, email, appID;

- (instancetype) init {
    self = [super init];
    
    if (self) {
//        self.appID = [Secret sharedSecret].DHAppID;
        
    }
    return self;
}
/*
- (void) createUser {
    @try {
        // setup for DH accountClient
        datahub_accountAccountServiceClient *account_client = [[Resources sharedResources] createDataHubAccountClient];
        [account_client create_account:username email:email password:password repo_name:@"getfit" app_id:appID app_token:appToken];
    } @catch (NSException *exception) {
        NSString *errorTitle;
        NSString *errorMessage;
        NSLog(@"%@", exception);
        
        if ([exception.name rangeOfString:@"datahub_accountAccountException"].location != NSNotFound) {
            datahub_accountAccountException *acctException = (datahub_accountAccountException*) exception;
            errorTitle = @"duplicate account";
            
            NSLog(@"%@", acctException.message);
            
            errorMessage = @"duplicate username and/or email detected. Please try another username or email.";
        } else {
            errorTitle = @"Connection Error";
            errorMessage = @"The app is unable to connect to datahub. Please check your wireless conntion.";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorTitle message:errorMessage delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
    
}

- (void) dropSchemaIfExists {
    NSString *dropScript = @"drop table getfit.device cascade; drop table getfit.battery cascade; drop table getfit.deviceinfo cascade; drop table getfit.motion cascade; drop table getfit.positioning cascade; drop table getfit.proximity cascade; drop table getfit.device cascade; drop table getfit.activity cascade; drop table getfit.minutes cascade; drop table getfit.opensense cascade;";
    
    datahubDataHubClient *datahub_client = [[Resources sharedResources] createDataHubClient];
    datahubConnectionParams *con_params_app = [[datahubConnectionParams alloc] initWithClient_id:nil seq_id:nil user:nil password:nil app_id:appID app_token:appToken repo_base:username];
    datahubConnection * con_app = [datahub_client open_connection:con_params_app];
    
    @try {
        datahubResultSet *result_set = [datahub_client execute_sql:con_app query:dropScript query_params:nil];
        NSLog(@"result_set: %@", result_set);
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}


- (void) createSchema {
    NSString *creationScript = @"create table getfit.device(    device_id varchar(50) primary key NOT NULL,    createdate timestamp default LOCALTIMESTAMP); create table getfit.battery(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    level integer,    state varchar(20));create table getfit.deviceinfo(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    brightness decimal,    country varchar(20),    language varchar(20),    system_version varchar(20));create table getfit.motion(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    attitude_pitch decimal,    attitude_roll decimal,    attitude_yaw decimal,    gravity_x decimal,    gravity_y decimal,    gravity_z decimal,    rotationRate_x decimal,    rotationRate_y decimal,    rotationRate_z decimal,    userAcceleration_x decimal,    userAcceleration_y decimal,    userAcceleration_z decimal);create table getfit.positioning(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    horizontal_accuracy decimal,    lat decimal,    lon decimal,    speed decimal,    course decimal,    altitude decimal,    vertical_accuracy decimal);create table getfit.proximity(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    state boolean);create table getfit.activity(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp NOT NULL,    activity varchar(50),    confidence varchar(50),    steps integer,    startDate timestamp NOT NULL,    endDate timestamp NOT NULL); create table getfit.minutes( minute_id SERIAL primary key, activity varchar(50), intensity varchar(20), duration integer, endDate timestamp); create table getfit.opensense ( id SERIAL primary key, data bytea);";
    
    datahubDataHubClient *datahub_client = [[Resources sharedResources] createDataHubClient];
    datahubConnectionParams *con_params_app = [[datahubConnectionParams alloc] initWithClient_id:nil seq_id:nil user:nil password:nil app_id:appID app_token:appToken repo_base:username];
    datahubConnection * con_app = [datahub_client open_connection:con_params_app];
    
    @try {
        datahubResultSet *result_set = [datahub_client execute_sql:con_app query:creationScript query_params:nil];
        NSLog(@"result_set: %@", result_set);
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
    }
}


// add a random string after the user's email, reducing collision risk.
- (NSString *) createUsername {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    email = [defaults objectForKey:@"email"];
    
    // strip the email of its extra characters
    NSRange range = [email rangeOfString:@"@"];
    email = [email substringToIndex:range.location];
    
    // create the string to append
    NSString *letters = @"abcdefghijklmnopqrstuvwxyz";
    int len = 4;
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((uint32_t)[letters length])]];
    }
    
    // append the string
    username = [NSString stringWithFormat:@"%@_%@", email, randomString];
    return username;
}

- (NSString *) createPassword {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    int len = 8;
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((uint32_t)[letters length])]];
    }
    return randomString;
    
}
*/
@end
