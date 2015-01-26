//
//  IntroAboutVC.m
//  GetFit
//
//  Created by Albert Carter on 1/22/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import "IntroAboutVC.h"

#include<unistd.h>
#include<netdb.h>

#import "IntroPageVC.h"
#import "IntroAuthorizationVC.h"
#import "DataHubCreation.h"



@interface IntroAboutVC ()
@property (weak, nonatomic) IntroPageVC *introPageVC;
@property (strong, nonatomic) CLLocationManager *locationMngr;
@end

@implementation IntroAboutVC
@synthesize introPageVC, continueButton, donateSwitch, noNetworkLabel, donateSensorLabel, donateLabel;


- (instancetype) initWithParentPageVC: (IntroPageVC *)parentPageVC {
    self = [super init];
    if (self) {
        self.introPageVC = parentPageVC;
        }
    return self;
}


- (void) viewWillAppear:(BOOL)animated {
    if (![self isNetworkAvailable:@"datahub.csail.mit.edu"]) {
        NSLog(@"Network not available");
        donateSwitch.hidden = YES;
        donateSwitch.hidden = YES;
        donateSensorLabel.hidden = YES;
        donateLabel.hidden = YES;
       
        
        UIColor *disabledBlue = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:0.2];
        [continueButton setTintColor:disabledBlue];
        [continueButton removeTarget:self action:@selector(tapToContinue:) forControlEvents:UIControlEventTouchUpInside];

        
        noNetworkLabel.text = @"Getfit cannot set up without a connection to the internet. Please try again later.";
        noNetworkLabel.hidden = NO;
        

    } else {
        donateSwitch.hidden = !YES;
        donateSwitch.hidden = !YES;
        donateSensorLabel.hidden = !YES;
        donateLabel.hidden = !YES;
        
        UIColor *enabledBlue = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
        [continueButton setTintColor:enabledBlue];
        [continueButton addTarget:self action:@selector(tapToContinue:) forControlEvents:UIControlEventTouchUpInside];

        
        noNetworkLabel.hidden = !NO;
    }
    
    
    NSString *donateLabelText = @"Donating sensor data requires your phone location.\nYour data is anonomous and it belongs to you. You can stop collection or delete your data at any time.";
    [donateLabel setText:donateLabelText];
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
    
    // set resumeSensorDate to the present. Background sensing is now turned on.
    if (donateSwitch.on) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSDate date] forKey:@"resumeSensorDate"];
        [defaults synchronize];
    }
    
    @try {
        NSNumber * newDataHubAcct = [dhCreation createDataHubUserFromEmail:email andUsername:username andPassword:password];
        NSLog(@"newDataHubAcct: %@", newDataHubAcct);
        [dhCreation createSchemaForUser:username];
        
        [defaults setObject:email forKey:@"email"];
        [defaults setObject:password forKey:@"password"];
        [defaults setObject:username forKey:@"username"];
        [defaults synchronize];

        
        [introPageVC pushDetailVC];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Creating Account" message:@"There was an error creating your account. Please try again later." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
    }
}

- (IBAction)donateChange:(id)sender {

    if([self.donateSwitch isOn]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Location Sensing?" message:@"\nDonating sensor data requires your app location.\n\nYour data is anonomous, and you can stop data collection or delete your data at any time." delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"ok", nil];
        [alert show];
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSDate distantFuture] forKey:@"resumeSensorDate"];
        [defaults synchronize];
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
        
        if ([self.locationMngr respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationMngr requestWhenInUseAuthorization];
        }
        [self.locationMngr startUpdatingLocation];
    }
}

-(BOOL)isNetworkAvailable:(NSString *)hostname
{
    const char *cHostname = [hostname UTF8String];
    struct hostent *hostinfo;
    hostinfo = gethostbyname (cHostname);
    if (hostinfo == NULL){
        return NO;
    }
    else{
        return YES;
    }
}


@end
