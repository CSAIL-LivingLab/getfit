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

//#import "datahub.h"
//#import <THTTPClient.h>
//#import <TBinaryProtocol.h>

@interface ViewController (){
//    Connection *dhConnection;
//    DataHubClient *dhServer;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)dbCreateUser:(id)sender {
    
    
}

- (IBAction)dbConnect:(id)sender {
    NSLog(@"dbconnect called");
    
//    @try {
//        NSURL *url = [NSURL URLWithString:@"http://datahub.csail.mit.edu/service"];
//        
//        // Talk to a server via HTTP, using a binary protocol
//        THTTPClient *transport = [[THTTPClient alloc] initWithURL:url];
//        TBinaryProtocol *protocol = [[TBinaryProtocol alloc]
//                                     initWithTransport:transport
//                                     strictRead:YES
//                                     strictWrite:YES];
//        
//        dhServer = [[DataHubClient alloc] initWithProtocol:protocol];
//        
//        ConnectionParams *conparams = [[ConnectionParams alloc] initWithClient_id:nil seq_id:nil user:@"al_carter" password:@"Gh6$U2!Y" repo_base:nil];
//        
//        dhConnection = [dhServer open_connection:conparams];
//        NSLog(@"Successfully establish db connection");
//    }
//    @catch (NSException *exception) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error"
//                                                        message:@"A connection could not be established"
//                                                       delegate:nil
//                                              cancelButtonTitle:@"OK"
//                                              otherButtonTitles:nil];
//        [alert show];
//    }
//    
    

}

- (IBAction)dbSelect:(id)sender {
//    ResultSet *results =  [dhServer execute_sql:dhConnection query:@"select * from test.demo" query_params:nil];
    
//    NSLog(@"%@", results);
}

- (IBAction)dbCreate:(id)sender {
    
//    ResultSet *repoCreation = [dhServer create_repo:dhConnection repo_name:@"getfit"];
//    NSLog(@"%@", repoCreation);
//    
//    
//    NSString *creationScript = @"create table getfit.device(    device_id varchar(50) primary key NOT NULL,    createdate timestamp default LOCALTIMESTAMP); create table getfit.battery(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    level integer,    state varchar(20));create table getfit.deviceinfo(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    brightness decimal,    country varchar(20),    language varchar(20),    system_version varchar(20));create table getfit.motion(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    attitude_pitch decimal,    attitude_roll decimal,    attitude_yaw decimal,    gravity_x decimal,    gravity_y decimal,    gravity_z decimal,    rotationRate_x decimal,    rotationRate_y decimal,    rotationRate_z decimal,    userAcceleration_x decimal,    userAcceleration_y decimal,    userAcceleration_z decimal);create table getfit.positioning(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    horizontal_accuracy decimal,    lat decimal,    lon decimal,    speed decimal,    course decimal,    altitude decimal,    vertical_accuracy decimal);create table getfit.proximity(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    state boolean);create table getfit.activity(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp NOT NULL,    activity varchar(50),    confidence varchar(50),    steps integer,    startDate timestamp NOT NULL,    endDate timestamp NOT NULL);";
//    
//    ResultSet *tableCreation =[dhServer execute_sql:dhConnection query:creationScript query_params:nil];
//    
//    NSLog(@"%@", tableCreation);
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
    
//    ResultSet *results =[dhServer delete_repo:dhConnection repo_name:@"getfit" force_if_non_empty:YES];
//    
//    NSLog(@"%@", results);
    
}

- (IBAction)getfitLogin:(id)sender {
    OAuthVC *oAuthVC = [[OAuthVC alloc]  init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:oAuthVC];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navController animated:YES completion:nil];
    
    
    
    

}

- (IBAction)showUI:(id)sender {
//    NSLog(@"pageVC presented");
////    GraphView *graphView = [[GraphView alloc] init];
////    [self presentViewController:graphView animated:YES completion:nil];
//    PageVC *pageVC = [[PageVC alloc] init];
//    [self presentViewController:pageVC animated:YES completion:nil];

}



@end
