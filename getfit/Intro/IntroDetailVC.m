//
//  IntroDetailVC.m
//  GetFit
//
//  Created by Albert Carter on 1/6/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import "IntroDetailVC.h"
#import "Secret.h"
#import "IntroPageVC.h"

#import "datahub.h"
#import "account.h"
#import <THTTPClient.h>
#import <TBinaryProtocol.h>

@interface IntroDetailVC ()
@property NSString * appID;
@property NSString *appToken;

@property datahubDataHubClient *dataHubClient;
@property NSURL *dataHubURL;

@property datahub_accountAccountServiceClient *accountClient;
@property NSURL *accountURL;


@end

@implementation IntroDetailVC
@synthesize thankYouLabel, setUpLabel, usernameStrLabel, passwordStrLabel, usernameLabel, passwordLabel, detailTextArea, spinnerIndicator, setupLabel, getfitButton, appID, appToken, dataHubClient, dataHubURL, accountClient, accountURL;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    getfitButton.hidden = YES;
    
    Secret *secret = [Secret sharedSecret];
    appID = [secret DHAppID];
    appToken = [secret DHAppToken];
    
    // show spinny thing, and setup up
    [self setUpDataHub]; //shows other things once it's done

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    
}

- (void) setUpDataHub {
    // username and password
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[self createPassword] forKey:@"password"];
    [defaults setObject:[self createUsername] forKey:@"username"];
    [defaults synchronize];
    
    NSString *email = [defaults objectForKey:@"email"];
    NSString *username = [defaults objectForKey:@"username"];
    NSString *password = [defaults objectForKey:@"password"];

//    [self createUser:username withEmail:email andPasword:password];
//    [self dropSchemaIfExists];
    [self createSchema];
    [self showResults];
}

- (void) createUser:(NSString *)username withEmail:(NSString*)email andPasword:(NSString *)password {
    @try {
        // setup for DH accountClient
        accountURL = [NSURL URLWithString:@"https://datahub.csail.mit.edu/service/account"];
        THTTPClient *transport = [[THTTPClient alloc] initWithURL:accountURL];
        TBinaryProtocol *protocol = [[TBinaryProtocol alloc]
                                     initWithTransport:transport
                                     strictRead:YES
                                     strictWrite:YES];
        accountClient = [[datahub_accountAccountServiceClient alloc] initWithProtocol:protocol];
        [accountClient create_account:username email:email password:password repo_name:@"getfit" app_id:appID app_token:appToken];
    } @catch (NSException *exception) {
        NSString *errorTitle;
        NSString *errorMessage;
        
        if ([exception.name rangeOfString:@"datahub_accountAccountException"].location != NSNotFound) {
            errorTitle = @"duplicate account";
            errorMessage = @"duplicate username and/or email detected. Please try another username or email.";
        } else {
            errorTitle = @"Connection Error";
            errorMessage = @"The app is unable to connect to datahub. Please check your wireless conntion.";
        }
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorTitle message:errorMessage delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }

}

- (void) createSchema {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [defaults objectForKey:@"email"];
    NSString *username = [defaults objectForKey:@"username"];
    NSString *password = [defaults objectForKey:@"password"];

    
    dataHubURL = [NSURL URLWithString:@"https://datahub.csail.mit.edu/service"];
    
    // Talk to a server via HTTP, using a binary protocol
    THTTPClient * transport = [[THTTPClient alloc] initWithURL:dataHubURL];
    
    TBinaryProtocol *protocol = [[TBinaryProtocol alloc]
                initWithTransport:transport
                strictRead:YES
                strictWrite:YES];
    
    datahubDataHubClient *client = [[datahubDataHubClient alloc] initWithProtocol:protocol];
    datahubConnectionParams *conparams = [[datahubConnectionParams alloc] initWithClient_id:nil seq_id:nil user:username password:password app_id:appID app_token:appToken repo_base:@"getfit"];
    datahubConnection *connection = [client open_connection:conparams];
    
    NSString *creationScript = @"create table getfit.device(    device_id varchar(50) primary key NOT NULL,    createdate timestamp default LOCALTIMESTAMP); create table getfit.battery(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    level integer,    state varchar(20));create table getfit.deviceinfo(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    brightness decimal,    country varchar(20),    language varchar(20),    system_version varchar(20));create table getfit.motion(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    attitude_pitch decimal,    attitude_roll decimal,    attitude_yaw decimal,    gravity_x decimal,    gravity_y decimal,    gravity_z decimal,    rotationRate_x decimal,    rotationRate_y decimal,    rotationRate_z decimal,    userAcceleration_x decimal,    userAcceleration_y decimal,    userAcceleration_z decimal);create table getfit.positioning(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    horizontal_accuracy decimal,    lat decimal,    lon decimal,    speed decimal,    course decimal,    altitude decimal,    vertical_accuracy decimal);create table getfit.proximity(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp not null,    state boolean);create table getfit.activity(    device_id_fk varchar(50) references getfit.device(device_id) NOT NULL,    datetime timestamp NOT NULL,    activity varchar(50),    confidence varchar(50),    steps integer,    startDate timestamp NOT NULL,    endDate timestamp NOT NULL); create table getfit.minutes( minute_id SERIAL primary key, activity varchar(50), intensity varchar(20), duration integer, endDate timestamp); create table getfit.opensense ( id SERIAL primary key, data bytea);";
    
    datahubResultSet *tableCreation =[client execute_sql:connection query:creationScript query_params:nil];
    
    NSLog(@"%@", tableCreation);
}


    // add a random string after the user's email, reducing collision risk.
- (NSString *) createUsername {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [defaults objectForKey:@"email"];
    
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
    NSString *username = [NSString stringWithFormat:@"%@_%@", email, randomString];
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

- (void) showResults {
    // hide setup stuff
    spinnerIndicator.hidden = YES;
    setupLabel.hidden = YES;
    
    // show new stuff
    thankYouLabel.hidden = NO;
    usernameStrLabel.hidden = NO;
    passwordStrLabel.hidden = NO;
    usernameLabel.hidden = NO;
    passwordLabel.hidden = NO;
    detailTextArea.hidden = NO;
    getfitButton.hidden = NO;
    
    
    detailTextArea.text = @"Use it to view your data at \nhttps://datahub.csail.mit.edu.\n\nThere's no need to write it down. You can access it anytime from this app, or reset it online.";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    usernameLabel.text = [defaults objectForKey:@"username"];
    passwordLabel.text = [defaults objectForKey:@"password"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)getfitButtonClick:(id)sender {
    NSLog(@"getFitButtonClicked");
    
    IntroPageVC *introPageVC = self.parentViewController;
    [introPageVC foo];
    [introPageVC dismissViewControllerAnimated:YES completion:nil];
    
    
}
@end
