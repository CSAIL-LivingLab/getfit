//
//  IntroVC.m
//  GetFit
//
//  Created by Albert Carter on 1/28/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import "IntroVC.h"

#include<unistd.h>
#include<netdb.h>

#import "DataHubCreation.h"

@interface IntroVC ()

@end

@implementation IntroVC {
    UIColor *blueColor;
    CGSize bounds;
    
    // first view
    UIView *firstView;
    UITextView *legalText;
    UIButton *acceptButton;
    UILabel *noNetworkLabel;

    // working view
    UIView *workingView;
    UILabel *workingLabel;
    UIActivityIndicatorView *workingSpinner;
    
    // second view
    UIView *secondView;
    UILabel *thankYouLabel;
    UILabel *setupLabel;
    UILabel *usernameInfoLabel;
    UILabel *usernameLabel;
    UILabel *passwordInfoLabel;
    UILabel *passwordLabel;
    UITextView *explanationView;
    
    UISwitch *donateSwitch;
    UILabel *donateSwitchLabel;
    UILabel *donateExplanationLabel;
    
    UIButton *goToGetFit;

    
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    bounds = [UIScreen mainScreen].bounds.size;
    blueColor = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
    
//    [self loadFirstPage];
    [self loadSecondPage];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadFirstPage {
    
    firstView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.width, bounds.height)];
    [self.view addSubview:firstView];
    
    // legal text
    NSString *htmlString = @"<style>* {font-family: \"Helvetica Neue\"; text-align:justify;}</style><h2>Intro</h2><p>This app allows you to record your activity data on your phone and submit this activity data to getfit@mit and upload it to your personal DataHub account. You must have a getfit@mit account and a DataHub account for the app to work.</p><p>Register for getfit@mit account at <a href=\"http://getfit.mit.edu/\">getfit.mit.edu</a></p><p>A DataHub account will be automatically created for you. To access DataHub login using the username and password found on “Info/About” tab.</p><h2>Logging Activities</h2><p>Users can “record” activity data using the Activity Tracking Timer. User selects Activity and Intensity (optional), and hits Start in order to begin recording activity data. Whenever possible users should keep phone on them during workout in order to log mobile sensor data. When activity is complete, press Stop and data will be saved and uploaded to getfit@mit [activityname; intensity; duration] and DataHub [activityname; intensity; duration; and sensor data]</p><p>Sensor data includes: motion sensors (gyroscope, accelerometer), activity info, position data and basic device info. It does not include call logs, audio, or video. </p><p>Users can record activity data using “manual entry” mode which allows user to submit [activityname; intensity; duration] to getfit@mit and to DataHub. In “manual entry” mode, sensors are not activated.</p><h2>Data</h2><p>This app will send your data to getfit@mit for the purposes of the Challenge and to DataHub for research. Data is stored in a secure database at MIT. Users will be able to login, access and edit their own personal data via their DataHub account. By using this app, users consent to sharing the data with the MIT Living Lab team. For research purposes, your data will be de-identified and combined with other user data for analysis. You can view or export your data any time you want. You can enable, pause or disable Continuous Data Logging Mode at any time. You may withdraw your consent and discontinue participation at any time.</p><h2>Consent</h2><p>By entering your name and date then tapping I Agree you consent to participate in the study and share your data. </p>";
    NSData *htmlData = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:htmlData options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    legalText = [[UITextView alloc] initWithFrame:CGRectMake(8, 70, bounds.width-16, bounds.height-150)];
    legalText.editable = NO;
    legalText.attributedText = attributedString;
    [legalText setContentOffset:CGPointMake(0, -200) animated:YES];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [firstView addSubview:legalText];
    
    CGFloat legalTextOffset = legalText.bounds.size.height + 55;
    
    // accept button
    acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(bounds.width/2-60, legalTextOffset + 30, 120, 30)];
    [acceptButton setTitle:@"I Accept" forState:UIControlStateNormal];
    [acceptButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [acceptButton setTitleColor:blueColor forState:UIControlStateNormal];
    [firstView addSubview:acceptButton];
    
    
    // no network label
    noNetworkLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, legalTextOffset + 10, bounds.width-16, 80)];
    noNetworkLabel.numberOfLines = 0;
    [noNetworkLabel setTextColor:[UIColor redColor]];
    [noNetworkLabel setFont:[UIFont systemFontOfSize:12]];
    [noNetworkLabel setTextAlignment:NSTextAlignmentCenter];
    [noNetworkLabel setText:@"You must be connected to the internet to set up GetFit. Please check your network connection and load the app again."];
    [firstView addSubview:noNetworkLabel];
    
    // network
    if (![self isNetworkAvailable:@"datahub.csail.mit.edu"]) {
        UIColor *disabledBlue = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:0.2];
        [acceptButton setTitleColor:disabledBlue forState:UIControlStateNormal];
        [acceptButton removeTarget:self action:@selector(accept:) forControlEvents:UIControlEventTouchUpInside];

    } else {
        noNetworkLabel.hidden = YES;
        [acceptButton addTarget:self action:@selector(accept:) forControlEvents:UIControlEventTouchUpInside];
    }
    
                    
    
}

- (void) loadSecondPage{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults objectForKey:@"username"];
    NSString *email = [defaults objectForKey:@"email"];
    
    // view
    secondView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.width, bounds.height)];
    [secondView setBackgroundColor:[UIColor whiteColor]];
    
    // thank you label
    thankYouLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 90, bounds.width-16, 20)];
    thankYouLabel.numberOfLines = 0;
    [thankYouLabel setText:@"Thank you for agreeing to participate!"];
    [thankYouLabel setTextAlignment:NSTextAlignmentCenter];
    [secondView addSubview:thankYouLabel];
    
    // setup label
    setupLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 120, bounds.width-16, 60)];
    setupLabel.numberOfLines = 0;
    [setupLabel setText:@"We've set up your GetFit DataHub account:"];
    [setupLabel setTextAlignment:NSTextAlignmentCenter];
    [secondView addSubview:setupLabel];
    
    CGFloat topLabelOffset = thankYouLabel.bounds.size.height + setupLabel.bounds.size.height + 80;
    
    // username/password info labels
    usernameInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(bounds.width/2-75, topLabelOffset +20, 70, 15)];
//    [usernameInfoLabel setBackgroundColor:[UIColor redColor]];
    [usernameInfoLabel setTextAlignment:NSTextAlignmentRight];
    [usernameInfoLabel setFont:[UIFont systemFontOfSize:14]];
    [usernameInfoLabel setText:@"username:"];
    [secondView addSubview:usernameInfoLabel];
    
    passwordInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(bounds.width/2-75, topLabelOffset +20 +20, 70, 15)];
//    [passwordInfoLabel setBackgroundColor:[UIColor redColor]];
    [passwordInfoLabel setTextAlignment:NSTextAlignmentRight];
    [passwordInfoLabel setFont:[UIFont systemFontOfSize:14]];
    [passwordInfoLabel setText:@"password:"];
    [secondView addSubview:passwordInfoLabel];

    // actual username and password
    usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(bounds.width/2 +5, topLabelOffset +20, 65, 15)];
//    [usernameLabel setBackgroundColor:[UIColor redColor]];
    [usernameLabel setTextAlignment:NSTextAlignmentLeft];
    [usernameLabel setFont:[UIFont systemFontOfSize:14]];
//    [usernameLabel setText:username];
    [usernameLabel setText:@"bdoijewf"];
    [secondView addSubview:usernameLabel];

    passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(bounds.width/2 +5, topLabelOffset +20 +20, 66, 15)];
//    [passwordLabel setBackgroundColor:[UIColor redColor]];
    [passwordLabel setTextAlignment:NSTextAlignmentLeft];
    [passwordLabel setFont:[UIFont systemFontOfSize:14]];
    //    [usernameLabel setText:username];
    [passwordLabel setText:@"bdoijewf"];
    [secondView addSubview:passwordLabel];
    
    CGFloat usernamePasswordOffset = 200;
    
    // explanationlabel
    explanationView = [[UITextView alloc] initWithFrame:CGRectMake(8, usernamePasswordOffset+30, bounds.width-16, 140)];
    [explanationView setFont:[UIFont systemFontOfSize:14]];
    [explanationView setText:@"Use it to view your data at\nhttps://www.datahub.csail.mit.edu.\n\nYou may want to write your username and password down. You can view them from ths app, but because the app is anonomous, we can't reset your password if it's lost."];
    [explanationView setEditable:NO];
    [explanationView setTextAlignment:NSTextAlignmentCenter];
    [explanationView setDataDetectorTypes:UIDataDetectorTypeAll];
    [explanationView sizeToFit];
    [secondView addSubview:explanationView];
    
    CGFloat explanationOffset =explanationView.frame.origin.y + explanationView.bounds.size.height;
    
    // button
    goToGetFit = [[UIButton alloc] initWithFrame:CGRectMake(bounds.width/2-50, explanationOffset + 5, 100, 100)];
    goToGetFit.layer.cornerRadius = goToGetFit.bounds.size.width/2;
    goToGetFit.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    goToGetFit.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [goToGetFit.layer setBackgroundColor:[blueColor CGColor]];
    [goToGetFit setTitle:@"Go to GetFit" forState:UIControlStateNormal];
    [goToGetFit.titleLabel setFont:[UIFont systemFontOfSize:15]];
    
//    _pauseButton.layer.cornerRadius = _pauseButton.bounds.size.width/2;
//    _pauseButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
//    _pauseButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
//    _pauseButton.layer.borderWidth = 2.0;
//    [_pauseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [[_pauseButton titleLabel] setFont:[UIFont fontWithName:kFONT_NAME size:15]];
//    [_pauseButton.layer setBackgroundColor:[blueColor CGColor]];

    
    
    [goToGetFit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [secondView addSubview:goToGetFit];
    
    // donate things are bottom alligned
    donateSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(30, bounds.height - 100, 60, 40)];
    donateSwitch.on = YES;
    [secondView addSubview:donateSwitch];
    
    donateSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, bounds.height - 105 , 330, 40)];
    [donateSwitchLabel setText:@"Donate Data to Living Labs"];
    [donateSwitchLabel setFont:[UIFont systemFontOfSize:15]];
    [secondView addSubview:donateSwitchLabel];
    
    donateExplanationLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, bounds.height - 65, bounds.width-16, 60)];
    donateExplanationLabel.numberOfLines = 0;
    [donateExplanationLabel setText:@"Donating sensor data requires your phone location.\nYour data belongs to you. At any time, you can stop collection from the phone, or delete your data from datahub, where it is stored."];
    [donateExplanationLabel setTextColor:[UIColor darkGrayColor]];
    [donateExplanationLabel setTextAlignment:NSTextAlignmentCenter];
    [donateExplanationLabel setFont:[UIFont systemFontOfSize:12]];
    [secondView addSubview:donateExplanationLabel];
    
    
//    donateSwitchLabel;
//    donateExplanationLabel;
    

    
    self.view = secondView;
}

- (void) loadWorkingPage{
    workingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.width, bounds.height)];
    [workingView setBackgroundColor:[UIColor whiteColor]];
    
    workingLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, bounds.height/2-30, bounds.width-16, 60)];
    workingLabel.numberOfLines = 0;
    [workingLabel setText:@"Setting up your DataHub account."];
    [workingLabel setTextColor:[UIColor grayColor]];
    [workingLabel setTextAlignment:NSTextAlignmentCenter];
    [workingView addSubview:workingLabel];
    
    workingSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(bounds.width/2-30, bounds.height/2+30, 60, 60)];
    workingSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [workingSpinner startAnimating];
    [workingView addSubview:workingSpinner];
    
    self.view = workingView;
    
}



# pragma mark - setup
- (void) accept:(id) sender {
    [self loadWorkingPage];
    [self setupDataHub];
}

- (void) setupDataHub{
    // make a username, password, and datahub account
    // record the results
    // put them into
    DataHubCreation *dhCreation = [[DataHubCreation alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *username = [dhCreation createRandomAlphaString];
    NSString *password = [dhCreation createRandomAlphaNumericString];
    NSString *email = [NSString stringWithFormat:@"albert.r.carter.mit+%@@gmail.com", username];
    
    @try {
        NSNumber * newDataHubAcct = [dhCreation createDataHubUserFromEmail:email andUsername:username andPassword:password];
        NSLog(@"newDataHubAcct: %@", newDataHubAcct);
        [dhCreation createSchemaForUser:username];
        
        [defaults setObject:email forKey:@"email"];
        [defaults setObject:password forKey:@"password"];
        [defaults setObject:username forKey:@"username"];
        [defaults synchronize];
        
        [self loadSecondPage];
    }
    @catch (NSException *exception) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Creating Account" message:@"There was an error creating your account. Please try again later." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [self loadFirstPage];
        [alert show];
    }

    
}

# pragma mark - helpers

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
