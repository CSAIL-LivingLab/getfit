//
//  IntroVC.m
//  GetFit
//
//  Created by Albert Carter on 1/28/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import "IntroVC.h"

@interface IntroVC ()

@end

@implementation IntroVC {
    // first view
    UIView *firstView;
    UITextView *legalText;
    UIButton *acceptButton;
    UILabel *noNetworkLabel;
    
    // second view
    UIView *secondView;
    UILabel *thankYouLabel;
    UILabel *setupLabel;
    UILabel *usernameLabel;
    UILabel *passwordLabel;
    UILabel *noNeedToWriteLabel;
    
    UISwitch *donateSwitch;
    UILabel *donateSwitchLabel;
    UILabel *donateExplanationLabel;
    
    UIButton *goToGetFit;

    
}



- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadFirstPage];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadFirstPage {
    CGSize bounds = [UIScreen mainScreen].bounds.size;
    
    firstView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.width, bounds.height)];
    [self.view addSubview:firstView];
    
    // legal text
    NSString *htmlString = @"<style>* {font-family: \"Helvetica Neue\"; text-align:justify;}</style><h2>Intro</h2><p>This app allows you to record your activity data on your phone and submit this activity data to getfit@mit and upload it to your personal DataHub account. You must have a getfit@mit account and a DataHub account for the app to work.</p><p>Register for getfit@mit account at <a href=\"http://getfit.mit.edu/\">getfit.mit.edu</a></p><p>A DataHub account will be automatically created for you. To access DataHub login using the username and password found on “Info/About” tab.</p><h2>Logging Activities</h2><p>Users can “record” activity data using the Activity Tracking Timer. User selects Activity and Intensity (optional), and hits Start in order to begin recording activity data. Whenever possible users should keep phone on them during workout in order to log mobile sensor data. When activity is complete, press Stop and data will be saved and uploaded to getfit@mit [activityname; intensity; duration] and DataHub [activityname; intensity; duration; and sensor data]</p><p>Sensor data includes: motion sensors (gyroscope, accelerometer), activity info, position data and basic device info. It does not include call logs, audio, or video. </p><p>Users can record activity data using “manual entry” mode which allows user to submit [activityname; intensity; duration] to getfit@mit and to DataHub. In “manual entry” mode, sensors are not activated.</p><h2>Data</h2><p>This app will send your data to getfit@mit for the purposes of the Challenge and to DataHub for research. Data is stored in a secure database at MIT. Users will be able to login, access and edit their own personal data via their DataHub account. By using this app, users consent to sharing the data with the MIT Living Lab team. For research purposes, your data will be de-identified and combined with other user data for analysis. You can view or export your data any time you want. You can enable, pause or disable Continuous Data Logging Mode at any time. You may withdraw your consent and discontinue participation at any time.</p><h2>Consent</h2><p>By entering your name and date then tapping Agree you consent to participate in the study and share your data. </p>";
    NSData *htmlData = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:htmlData options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];

    
    legalText = [[UITextView alloc] initWithFrame:CGRectMake(8, 55, bounds.width-16, bounds.height-150)];
    legalText.editable = NO;
    legalText.attributedText = attributedString;
    [legalText setContentOffset:CGPointMake(0, -200) animated:YES];
    //introTextView.contentInset = UIEdgeInsetsMake(10, 10, 10, 10);
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    [firstView addSubview:legalText];
    
    
    
}

- (void) loadSecondPage{
    
}


@end
