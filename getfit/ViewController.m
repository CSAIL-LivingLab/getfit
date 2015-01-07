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
#import "Secret.h"

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
/*
- (void)viewDidLoad {
    
    [super viewDidLoad];
    url = [NSURL URLWithString:@"https://datahub.csail.mit.edu/service"]; // chose you server
    
    // Talk to a server via HTTP, using a binary protocol
    transport = [[THTTPClient alloc] initWithURL:url];
    
    protocol = [[TBinaryProtocol alloc]
                                 initWithTransport:transport
                                 strictRead:YES
                                 strictWrite:YES];
}


- (IBAction)dbCreateUser:(id)sender {
//    Secret *secret = [Secret sharedSecret];
//    
//    datahub_accountAccountServiceClient *accountClient = [[datahub_accountAccountServiceClient alloc] initWithProtocol:protocol];
//    
//    // create
//    [accountClient create_account:@"norm" email:@"albert.r.carter.mit@gmail.com" password:@"ACCOUNT PASSWORD" app_id:@"APP_ID" app_token:@"APP_TOKEN"];
//    
//    // delete
//    [accountClient remove_account:@"ACCOUNT_NAME" app_id:@"APP_ID" app_token:@"APP_TOKEN"];
//}

//- (IBAction)dbConnect:(id)sender {
//    Secret *secret = [Secret sharedSecret];
//
//    @try {
//        client = [[datahubDataHubClient alloc] initWithProtocol:protocol];
//        conparams = [[datahubConnectionParams alloc] initWithClient_id:@"foo" seq_id:nil user:secret.DHSuperUser password:secret.DHSuperUserPassword repo_base:nil];
//        connection = [client open_connection:conparams];
//        
//        if (connection == nil) {
//            [NSException raise:@"No connection detected" format:nil];
//        }
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Success"
//                                                        message:@"Established a connection to datahub"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
//        
//    } @catch (NSException *exception) {
//        NSLog(@"Connect Exception: %@", exception);
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error"
//                                                        message:@"A connection could not be established"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//          [alert show];
//    }
//}
    

/*
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
 */
/*
- (IBAction)dbCreate:(id)sender {
    @try {
        if (connection == nil) {
            [NSException raise:@"No connection detected" format:nil];
        }
        
        datahubResultSet *repoCreation = [client create_repo:connection repo_name:@"getfit"];
        NSLog(@"%@", repoCreation);
        NSString *creationScript = @"create table getfit.device(    device_id varchar(50) primary key NOT NULL,    createdate timestamp default LOCALTIMESTAMP); create table getfit.battery(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    level integer,    state varchar(20));create table getfit.deviceinfo(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    brightness decimal,    country varchar(20),    language varchar(20),    system_version varchar(20));create table getfit.motion(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    attitude_pitch decimal,    attitude_roll decimal,    attitude_yaw decimal,    gravity_x decimal,    gravity_y decimal,    gravity_z decimal,    rotationRate_x decimal,    rotationRate_y decimal,    rotationRate_z decimal,    userAcceleration_x decimal,    userAcceleration_y decimal,    userAcceleration_z decimal);create table getfit.positioning(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    horizontal_accuracy decimal,    lat decimal,    lon decimal,    speed decimal,    course decimal,    altitude decimal,    vertical_accuracy decimal);create table getfit.proximity(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    state boolean);create table getfit.activity(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp NOT NULL,    activity varchar(50),    confidence varchar(50),    steps integer,    startDate timestamp NOT NULL,    endDate timestamp NOT NULL); create table getfit.minutes( minute_id SERIAL primary key, activity varchar(50), intensity varchar(20), duration integer, endDate timestamp);";
        
        datahubResultSet *tableCreation =[client execute_sql:connection query:creationScript query_params:nil];
        
        NSLog(@"%@", tableCreation);

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Creation of repo/tables success"
                                                        message:@"Check the log for details."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Creation Error"
                                                        message:@"Maybe the repo already existed, or you forgot to connect? \n\nCheck the log for details."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

    }
    
    
    
    }

- (IBAction)dbGrant:(id)sender {
    
//    
//    datahubCollaborator *collaborator = [[datahubCollaborator alloc] initWithCollaborator_type:1 name:@("anant")];
//    datahubPrivilege *priviledge = [[datahubPrivilege alloc] initWithRepo_privilege:(datahubRepoPrivilege *) table_privilege:(datahubTablePrivilege *)]
//    [client add_collaborator:connection collaborator:collaborator privilege:<#(datahubPrivilege *)#>]
//    
//    
//    - (datahubResultSet *) add_collaborator: (datahubConnection *) con collaborator: (datahubCollaborator *) collaborator privilege: (datahubPrivilege *) privilege;  // throws datahubDBException *, TException
    if (connection == nil) {
        [NSException raise:@"No connection detected" format:nil];
    }
    
    @try {
        NSString *grantScript0 = @"grant usage on schema getfit to arcartercsail;";
        NSString *grantScript1 = @"grant all on all tables in schema getfit to arcartercsail;";
        
        datahubResultSet *results0 =[client execute_sql:connection query:grantScript0 query_params:nil];
        datahubResultSet *results1 =[client execute_sql:connection query:grantScript1 query_params:nil];
        NSLog(@"%@", results0);
        NSLog(@"%@", results1);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Grant Success"
                                                        message:@"Successfully PROGRAMMATICALLY granted access to albertrcartercsail.\n\n Check the log for details."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Grant Error"
                                                        message:@"Maybe the repo doesn't exist, or you forgot to connect? \n\nCheck the log for details."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
}
/*
- (IBAction)dbDelete:(id)sender {
    @try {
        if (connection == nil) {
            [NSException raise:@"No connection detected" format:nil];
        }
        
        datahubResultSet *results =[client delete_repo:connection repo_name:@"getfit" force_if_non_empty:YES];
        NSLog(@"%@", results);
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Deletion Success"
                                                        message:@"Successfully deleted getfit repo"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Deletion Error"
                                                        message:@"Maybe the repo doesn't exist, or you forgot to connect? \n\nCheck the log for details."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

- (IBAction)getfitLogin:(id)sender {
    OAuthVC *oAuthVC = [[OAuthVC alloc]  init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:oAuthVC];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navController animated:YES completion:nil];
    
 
}*/


@end

