//
//  ViewController.m
//  GetFit
//
//  Created by Albert Carter on 12/3/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import "ViewController.h"
#import "OAuthVC.h"
#import "PageVC.h"
//#import "GraphView.h"

#import "datahub.h"
#import "account.h"
#import <THTTPClient.h>
#import <TBinaryProtocol.h>

@interface ViewController (){
    THTTPClient *transport;
    TBinaryProtocol *protocol;
    NSURL *url;
    
    datahubDataHubClient *client;
    datahubConnectionParams *conparams;
    datahubConnection *connection;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    url = [NSURL URLWithString:@"http://datahub.csail.mit.edu/service"]; // chose you server
    
    // Talk to a server via HTTP, using a binary protocol
    transport = [[THTTPClient alloc] initWithURL:url];
    
    protocol = [[TBinaryProtocol alloc]
                                 initWithTransport:transport
                                 strictRead:YES
                                 strictWrite:YES];
}


- (IBAction)dbCreateUser:(id)sender {
    datahub_accountAccountServiceClient *accountClient = [[datahub_accountAccountServiceClient alloc] initWithProtocol:protocol];
    
    // create
    [accountClient create_account:@"ACCOUNT_NAME" email:@"ACCOUNT_EMAIL" password:@"ACCOUNT PASSWORD" app_id:@"APP_ID" app_token:@"APP_TOKEN"];
    
    // delete
    [accountClient remove_account:@"ACCOUNT_NAME" app_id:@"APP_ID" app_token:@"APP_TOKEN"];
}

- (IBAction)dbConnect:(id)sender {
    @try {
        client = [[datahubDataHubClient alloc] initWithProtocol:protocol];
        conparams = [[datahubConnectionParams alloc] initWithClient_id:@"foo" seq_id:nil user:@"anantb" password:@"anant" repo_base:nil];
        connection = [client open_connection:conparams];
        
        if (connection == nil) {
            [NSException raise:@"No connection detected" format:nil];
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Success"
                                                        message:@"Established a connection to datahub"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
    } @catch (NSException *exception) {
        NSLog(@"Connect Exception: %@", exception);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error"
                                                        message:@"A connection could not be established"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
          [alert show];
    }
}
    


- (IBAction)dbSelect:(id)sender {
    @try {
        if (connection == nil) {
            [NSException raise:@"No connection detected" format:nil];
        }
        
        datahubResultSet *results =  [client execute_sql:connection query:@"select * from test.demo" query_params:nil];
        NSLog(@"%@", results);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Query Success"
                                                        message:@"Check the log for details."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    @catch (NSException *exception) {
        NSLog(@"Query Exception: %@", exception);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Query Error"
                                                        message:@"Maybe you forgot to establish a connection?\n\nCheck the log for details."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)dbCreate:(id)sender {
    
    datahubResultSet *repoCreation = [client create_repo:connection repo_name:@"getfit"];
    NSLog(@"%@", repoCreation);
    
    
    NSString *creationScript = @"create table getfit.device(    device_id varchar(50) primary key NOT NULL,    createdate timestamp default LOCALTIMESTAMP); create table getfit.battery(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    level integer,    state varchar(20));create table getfit.deviceinfo(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    brightness decimal,    country varchar(20),    language varchar(20),    system_version varchar(20));create table getfit.motion(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    attitude_pitch decimal,    attitude_roll decimal,    attitude_yaw decimal,    gravity_x decimal,    gravity_y decimal,    gravity_z decimal,    rotationRate_x decimal,    rotationRate_y decimal,    rotationRate_z decimal,    userAcceleration_x decimal,    userAcceleration_y decimal,    userAcceleration_z decimal);create table getfit.positioning(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    horizontal_accuracy decimal,    lat decimal,    lon decimal,    speed decimal,    course decimal,    altitude decimal,    vertical_accuracy decimal);create table getfit.proximity(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    state boolean);create table getfit.activity(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp NOT NULL,    activity varchar(50),    confidence varchar(50),    steps integer,    startDate timestamp NOT NULL,    endDate timestamp NOT NULL);";
    
    datahubResultSet *tableCreation =[client execute_sql:connection query:creationScript query_params:nil];
    
    NSLog(@"%@", tableCreation);
}

- (IBAction)dbGrant:(id)sender {
    //    NSString *grantScript0 = @"grant usage on schema getfit to arcartercsail;";
    //    NSString *grantScript1 = @"grant all on all tables in schema getfit to arcartercsail;";
    //
    //    ResultSet *results0 =[dhServer execute_sql:dhConnection query:grantScript0 query_params:nil];
    //    ResultSet *results1 =[dhServer execute_sql:dhConnection query:grantScript1 query_params:nil];
    //    NSLog(@"%@", results0);
    //    NSLog(@"%@", results1);
}

- (IBAction)dbDelete:(id)sender {
    
    datahubResultSet *results =[client delete_repo:connection repo_name:@"getfit" force_if_non_empty:YES];
    
    NSLog(@"%@", results);
    
}

- (IBAction)getfitLogin:(id)sender {
    OAuthVC *oAuthVC = [[OAuthVC alloc]  init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:oAuthVC];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navController animated:YES completion:nil];
    
 
}


@end

