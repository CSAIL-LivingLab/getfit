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
@synthesize introPageVC, continueButton, donateSwitch, noNetworkLabel, donateSensorLabel, donateLabel, introTextView;


- (instancetype) initWithParentPageVC: (IntroPageVC *)parentPageVC {
    self = [super init];
    if (self) {
        self.introPageVC = parentPageVC;
        }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    
    NSString *htmlString = @"<style>* {font-family: \"Helvetica Neue\"; text-align:justify;}</style><h2>Intro</h2><p>This app allows you to record your activity data on your phone and submit this activity data to getfit@mit and upload it to your personal DataHub account. You must have a getfit@mit account and a DataHub account for the app to work.</p><p>Register for getfit@mit account at <a href=\"http://getfit.mit.edu/\">getfit.mit.edu</a></p><p>A DataHub account will be automatically created for you. To access DataHub login using the username and password found on “Info/About” tab.</p><h2>Logging Activities</h2><p>Users can “record” activity data using the Activity Tracking Timer. User selects Activity and Intensity (optional), and hits Start in order to begin recording activity data. Whenever possible users should keep phone on them during workout in order to log mobile sensor data. When activity is complete, press Stop and data will be saved and uploaded to getfit@mit [activityname; intensity; duration] and DataHub [activityname; intensity; duration; and sensor data]</p><p>Sensor data includes: motion sensors (gyroscope, accelerometer), activity info, position data and basic device info. It does not include call logs, audio, or video. </p><p>Users can record activity data using “manual entry” mode which allows user to submit [activityname; intensity; duration] to getfit@mit and to DataHub. In “manual entry” mode, sensors are not activated.</p><h2>Data</h2><p>This app will send your data to getfit@mit for the purposes of the Challenge and to DataHub for research. Data is stored in a secure database at MIT. Users will be able to login, access and edit their own personal data via their DataHub account. By using this app, users consent to sharing the data with the MIT Living Lab team. For research purposes, your data will be de-identified and combined with other user data for analysis. You can view or export your data any time you want. You can enable, pause or disable Continuous Data Logging Mode at any time. You may withdraw your consent and discontinue participation at any time.</p><h2>Consent</h2><p>By entering your name and date then tapping Agree you consent to participate in the study and share your data. XXX</p>";
    NSData *htmlData = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:htmlData options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    introTextView.attributedText = attributedString;
    [introTextView setContentOffset:CGPointMake(0, -200) animated:YES];
    introTextView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.automaticallyAdjustsScrollViewInsets = NO;

    // network availability checks
    if (![self isNetworkAvailable:@"datahub.csail.mit.edu"]) {
        NSLog(@"Network not available");
        donateSwitch.hidden = YES;
        donateSwitch.hidden = YES;
        donateSensorLabel.hidden = YES;
        donateLabel.hidden = YES;
       
        
        UIColor *disabledBlue = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:0.2];
        [continueButton setTintColor:disabledBlue];
        [continueButton removeTarget:self action:@selector(tapToContinue:) forControlEvents:UIControlEventTouchUpInside];

        
        noNetworkLabel.text = @"You must be connected to the Internet to set up GetFit. Check your settings and try again.";
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
