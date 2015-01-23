//
//  IntroAboutVC.m
//  GetFit
//
//  Created by Albert Carter on 1/22/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import "IntroAboutVC.h"

#import "IntroPageVC.h"
#import "IntroAuthorizationVC.h"
#import "DataHubCreation.h"



@interface IntroAboutVC ()
@property (weak, nonatomic) IntroPageVC *introPageVC;
@property (strong, nonatomic) CLLocationManager *locationMngr;
@end

@implementation IntroAboutVC
@synthesize introPageVC, continueButton;


- (instancetype) initWithParentPageVC: (IntroPageVC *)parentPageVC {
    self = [super init];
    if (self) {
        self.introPageVC = parentPageVC;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - things

- (IBAction)tapToContinue:(id)sender {
    self.locationMngr = nil;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    DataHubCreation *dhCreation = [[DataHubCreation alloc] init];
    
    NSString *username = [dhCreation createRandomAlphaString];
    NSString *password = [dhCreation createRandomAlphaNumericString];
    NSString *email = [NSString stringWithFormat:@"albert.r.carter.mit+%@@gmail.com", username];

//    NSString *username = @"nnnnnkod";
//    NSString *password = @"lizlees";
//    NSString *email = @"gerjiowf@iow.riw";
    
    [defaults setObject:email forKey:@"email"];
    [defaults setObject:password forKey:@"password"];
    [defaults setObject:username forKey:@"username"];
    [defaults synchronize];

    NSNumber * newDataHubAcct = [dhCreation createDataHubUserFromEmail:email andUsername:username andPassword:password];
    NSLog(@"newDataHubAcct: %@", newDataHubAcct);
    [dhCreation createSchemaForUser:username];
    [introPageVC pushDetailVC];
}

- (IBAction)donateChange:(id)sender {

    if([self.donateSwitch isOn]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Location Sensing?" message:@"\nDonating sensor data requires your app location.\n\nYour data is anonomous, and you can stop data collection or delete your data at any time." delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
        [alert show];
    } else {
        NSLog(@"switch off");
    }
    
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    // app requests user location
    if (buttonIndex == 0) {
        [self.donateSwitch setOn:NO];
    } else {
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSDate date] forKey:@"resumeSensorDate"];
        [defaults synchronize];
        NSLog(@"ok");
        
        self.locationMngr = [[CLLocationManager alloc] init];
        [self.locationMngr requestAlwaysAuthorization];
    }
}

@end
