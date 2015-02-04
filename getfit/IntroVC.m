//
//  IntroVC.m
//  GetFit
//
//  Created by Albert Carter on 1/28/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import "IntroVC.h"

// only use the appDelegate for starting the location manager
#import "AppDelegate.h"
#include<unistd.h>
#include<netdb.h>

#import "IntroAuthorizationVC.h"
#import "DataHubCreation.h"

@interface IntroVC ()

@end

@implementation IntroVC {
    UIColor *blueColor;
    UIColor *greenColor;
    CGSize bounds;
    BOOL *randomAcct;
    
    // first view
    UIView *firstView;
    UITextView *legalText;
    UIButton *acceptButton;
    UILabel *noNetworkLabel;

    // working view
    UIView *workingView;
    UILabel *workingLabel;
    UIActivityIndicatorView *workingSpinner;
    
    // choice View
    UIView *choiceView;
    UIButton *anonomousButton;
    UIButton *emailButton;
    UITextField *emailTextField;
    UITextView *datahubAcctExplanationTextView;
    NSString *explanationText;
    UIButton *cancelButton;
    UIButton *createButton;
    
    // final view
    UIView *finalView;
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


- (void)viewDidLoad {
    [super viewDidLoad];
    
    bounds = [UIScreen mainScreen].bounds.size;
    blueColor = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
    greenColor = [UIColor colorWithRed:.1 green:.8 blue:.1 alpha:1.0];
    
    [self loadFirstView];
//    [self loadChoiceView];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loadFirstView {
    [self setTitle:@"Welcome to GetFit for iOS"];

    firstView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.width, bounds.height)];
    [firstView setBackgroundColor:[UIColor blackColor]];
    [self.view addSubview:firstView];
    
    // legal text
    NSString *htmlString = @"<style>* {font-family: \"Helvetica Neue\"; text-align:justify;}</style><h2>Intro</h2><p>This app allows you to record your activity data on your phone and submit this activity data to getfit@mit and upload it to your personal DataHub account. You must have a getfit@mit account and a DataHub account for the app to work.</p><p>Register for getfit@mit account at <a href=\"http://getfit.mit.edu/\">getfit.mit.edu</a></p><p>A DataHub account will be automatically created for you. To access DataHub login using the username and password found on “Info/About” tab.</p><h2>Logging Activities</h2><p>Users can “record” activity data using the Activity Tracking Timer. User selects Activity and Intensity (optional), and hits Start in order to begin recording activity data. Whenever possible users should keep phone on them during workout in order to log mobile sensor data. When activity is complete, press Stop and data will be saved and uploaded to getfit@mit [activityname; intensity; duration] and DataHub [activityname; intensity; duration; and sensor data]</p><p>Sensor data includes: motion sensors (gyroscope, accelerometer), activity info, position data and basic device info. It does not include call logs, audio, or video. </p><p>Users can record activity data using “manual entry” mode which allows user to submit [activityname; intensity; duration] to getfit@mit and to DataHub. In “manual entry” mode, sensors are not activated.</p><h2>Data</h2><p>This app will send your data to getfit@mit for the purposes of the Challenge and to DataHub for research. Data is stored in a secure database at MIT. Users will be able to login, access and edit their own personal data via their DataHub account. By using this app, users consent to sharing the data with the MIT Living Lab team. For research purposes, your data will be de-identified and combined with other user data for analysis. You can view or export your data any time you want. You can enable, pause or disable Continuous Data Logging Mode at any time. You may withdraw your consent and discontinue participation at any time.</p><h2>Consent</h2><p>By entering your name and date then tapping I Agree you consent to participate in the study and share your data. </p>";
    NSData *htmlData = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:htmlData options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    legalText = [[UITextView alloc] initWithFrame:CGRectMake(8, 70, bounds.width-16, bounds.height-140)];
    legalText.editable = NO;
    legalText.attributedText = attributedString;
    [legalText setContentOffset:CGPointMake(0, -200) animated:YES];
    self.automaticallyAdjustsScrollViewInsets = NO;
    [legalText setBackgroundColor:[UIColor clearColor]];
    [legalText setTextColor:[UIColor whiteColor]];
    [firstView addSubview:legalText];
    
    CGFloat legalTextOffset = legalText.frame.size.height + legalText.frame.origin.y;
    
    // accept button
    acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(bounds.width/2-35, legalTextOffset+2, 65, 65)];
    acceptButton.layer.cornerRadius = acceptButton.bounds.size.width/2;
    acceptButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    acceptButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [acceptButton.layer setBackgroundColor:[blueColor CGColor]];

//    [acceptButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [acceptButton setTitle:@"I Accept" forState:UIControlStateNormal];
    [acceptButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [acceptButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    
    
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

- (void) loadChoiceView{
    [self setTitle:@"Please Select an Account Type"];
    choiceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.width, bounds.height)];
    [choiceView setBackgroundColor:[UIColor blackColor]];
    
    CGFloat largeButtonWidth = 140;
    CGFloat smallButtonWidth = 140;
    
    CGFloat buttonOffsetY = bounds.height/2-largeButtonWidth/2;
    CGFloat fieldsOffsetY = 145;
    
    // select anonomous account
    anonomousButton = [[UIButton alloc] initWithFrame:CGRectMake(10, buttonOffsetY, largeButtonWidth, largeButtonWidth)];
    anonomousButton.layer.cornerRadius = largeButtonWidth/2;
    anonomousButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    anonomousButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [anonomousButton setBackgroundColor:blueColor];
    [anonomousButton setTitle:@"Create an anonomous account" forState:UIControlStateNormal];
    [anonomousButton.titleLabel setNumberOfLines:0];
    [anonomousButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [anonomousButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [anonomousButton addTarget:self action:@selector(anonomousButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [choiceView addSubview:anonomousButton];
    
    // select account using email
    emailButton = [[UIButton alloc] initWithFrame:CGRectMake(bounds.width-10-largeButtonWidth, buttonOffsetY, largeButtonWidth, largeButtonWidth)];
    emailButton.layer.cornerRadius = largeButtonWidth/2;
    emailButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    emailButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [emailButton setBackgroundColor:greenColor];
    [emailButton setTitle:@"Create an\naccount using\nyour email" forState:UIControlStateNormal];
    [emailButton.titleLabel setNumberOfLines:0];
    [emailButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [emailButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [emailButton addTarget:self action:@selector(emailButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [choiceView addSubview:emailButton];

    /* Fields that will appear after tapping one of the above buttons. 
     These start as hidden with clearColor or alpha = 0 */

    
    // field that email goes into
    emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, fieldsOffsetY + 15, bounds.width - 30, 40)];
    emailTextField.hidden = YES;
//    [emailTextField setTextColor:[UIColor clearColor]];
    emailTextField.alpha = 0;
    [emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    [emailTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [emailTextField setTextAlignment:NSTextAlignmentCenter];
    [emailTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [emailTextField setPlaceholder:@"your email"];
    [choiceView addSubview:emailTextField];
    
    // dismiss the keybord on tap background
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [tapBackground setNumberOfTapsRequired:1];
    [choiceView addGestureRecognizer:tapBackground];

    CGFloat emailTextFieldOffset = emailTextField.frame.origin.y + emailTextField.frame.size.height;
    
    cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, emailTextFieldOffset + 15, smallButtonWidth, smallButtonWidth)];
    cancelButton.layer.cornerRadius = smallButtonWidth/2;
    cancelButton.hidden = YES;
    cancelButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [cancelButton setBackgroundColor:[UIColor clearColor]];
    [cancelButton setTitle:@"cancel" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [cancelButton addTarget:self action:@selector(cancelButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [choiceView addSubview:cancelButton];

    
    createButton = [[UIButton alloc] initWithFrame:CGRectMake(bounds.width - 10 - smallButtonWidth, emailTextFieldOffset + 15, smallButtonWidth, smallButtonWidth)];
    createButton.layer.cornerRadius = smallButtonWidth/2;
    createButton.hidden = YES;
    createButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    createButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [createButton setBackgroundColor:[UIColor clearColor]];
    [createButton setTitle:@"create" forState:UIControlStateNormal];
    [createButton.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [createButton addTarget:self action:@selector(createButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [choiceView addSubview:createButton];

    // explanation of account type
    explanationText = @"Tap on each button for more information.\n\nYou will have an opportunity to go back to view other options.";
    datahubAcctExplanationTextView = [[UITextView alloc] initWithFrame:CGRectMake(8, bounds.height-170, bounds.width-16, 170)];
    datahubAcctExplanationTextView.hidden = NO;
    datahubAcctExplanationTextView.alpha = 1;
    [datahubAcctExplanationTextView setText:explanationText];
    [datahubAcctExplanationTextView setTextAlignment:NSTextAlignmentCenter];
    [datahubAcctExplanationTextView setFont:[UIFont systemFontOfSize:15]];
    [datahubAcctExplanationTextView setBackgroundColor:[UIColor clearColor]];
    [datahubAcctExplanationTextView setTextColor:[UIColor whiteColor]];
    [choiceView addSubview:datahubAcctExplanationTextView];
    
    self.view = choiceView;
}

- (void) loadFinalView{
    [self setTitle:@"You're Done With Set Up!"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults objectForKey:@"username"];
    NSString *password = [defaults objectForKey:@"password"];
    
    // view
    finalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.width, bounds.height)];
    [finalView setBackgroundColor:[UIColor blackColor]];
    
    // thank you label
    thankYouLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 90, bounds.width-16, 20)];
    thankYouLabel.numberOfLines = 0;
    [thankYouLabel setText:@"Thank you for agreeing to participate!"];
    [thankYouLabel setTextColor:[UIColor whiteColor]];
    [thankYouLabel setTextAlignment:NSTextAlignmentCenter];
    [finalView addSubview:thankYouLabel];
    
    // setup label
    setupLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 120, bounds.width-16, 60)];
    setupLabel.numberOfLines = 0;
    [setupLabel setText:@"We've set up your GetFit DataHub account:"];
    [setupLabel setTextColor:[UIColor whiteColor]];
    [setupLabel setTextAlignment:NSTextAlignmentCenter];
    [finalView addSubview:setupLabel];
    
    CGFloat topLabelOffset = thankYouLabel.bounds.size.height + setupLabel.bounds.size.height + 80;
    
    // username/password info labels
    usernameInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(bounds.width/2-75, topLabelOffset +20, 70, 15)];
    [usernameInfoLabel setTextColor:[UIColor whiteColor]];
    [usernameInfoLabel setTextAlignment:NSTextAlignmentRight];
    [usernameInfoLabel setFont:[UIFont systemFontOfSize:14]];
    [usernameInfoLabel setText:@"username:"];
    [finalView addSubview:usernameInfoLabel];
    
    passwordInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(bounds.width/2-75, topLabelOffset +20 +20, 70, 15)];
    [passwordInfoLabel setTextColor:[UIColor whiteColor]];
    [passwordInfoLabel setTextAlignment:NSTextAlignmentRight];
    [passwordInfoLabel setFont:[UIFont systemFontOfSize:14]];
    [passwordInfoLabel setText:@"password:"];
    [finalView addSubview:passwordInfoLabel];

    // actual username and password
    usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(bounds.width/2 +5, topLabelOffset +20, 75, 15)];
    [usernameLabel setTextColor:[UIColor whiteColor]];
    [usernameLabel setTextAlignment:NSTextAlignmentLeft];
    [usernameLabel setFont:[UIFont systemFontOfSize:14]];
    [usernameLabel setText:username];
//    [usernameLabel setText:@"bdoijewf"];
    [finalView addSubview:usernameLabel];

    passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(bounds.width/2 +5, topLabelOffset +20 +20, 75, 15)];
    [passwordLabel setTextColor:[UIColor whiteColor]];
    [passwordLabel setTextAlignment:NSTextAlignmentLeft];
    [passwordLabel setFont:[UIFont systemFontOfSize:14]];
        [passwordLabel setText:password];
//    [passwordLabel setText:@"bdoijewf"];
    [finalView addSubview:passwordLabel];
    
    CGFloat usernamePasswordOffset = 200;
    
    // explanationlabel
    explanationView = [[UITextView alloc] initWithFrame:CGRectMake(8, usernamePasswordOffset+30, bounds.width-16, 140)];
    [explanationView setFont:[UIFont systemFontOfSize:14]];
    [explanationView setText:@"Use it to view your data at\nhttps://www.datahub.csail.mit.edu\n\nYou may want to write your username and password down. You can view them from ths app, but because the app is anonomous, we can't reset your password if it's lost."];
    [explanationView setTextColor:[UIColor whiteColor]];
    [explanationView setBackgroundColor:[UIColor clearColor]];
    [explanationView setEditable:NO];
    [explanationView setTextAlignment:NSTextAlignmentCenter];
    [explanationView setDataDetectorTypes:UIDataDetectorTypeAll];
    [explanationView sizeToFit];
    [finalView addSubview:explanationView];
    
    CGFloat explanationOffset =explanationView.frame.origin.y + explanationView.bounds.size.height;
    
    // button
    goToGetFit = [[UIButton alloc] initWithFrame:CGRectMake(bounds.width/2-50, explanationOffset, 100, 100)];
    goToGetFit.layer.cornerRadius = goToGetFit.bounds.size.width/2;
    goToGetFit.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    goToGetFit.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [goToGetFit.layer setBackgroundColor:[blueColor CGColor]];
    [goToGetFit setTitle:@"Go to GetFit" forState:UIControlStateNormal];
    [goToGetFit.titleLabel setFont:[UIFont systemFontOfSize:15]];
    
    [goToGetFit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [goToGetFit addTarget:self action:@selector(goToGetFit:) forControlEvents:UIControlEventTouchUpInside];
    [finalView addSubview:goToGetFit];
    
    // donate things are bottom alligned
    donateSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(30, bounds.height - 100, 60, 40)];
    donateSwitch.on = YES;
    [finalView addSubview:donateSwitch];
    
    donateSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, bounds.height - 105 , 330, 40)];
    [donateSwitchLabel setText:@"Donate Data to Living Labs"];
    [donateSwitchLabel setTextColor:[UIColor whiteColor]];
    [donateSwitchLabel setFont:[UIFont systemFontOfSize:15]];
    [finalView addSubview:donateSwitchLabel];
    
    donateExplanationLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, bounds.height - 65, bounds.width-16, 60)];
    donateExplanationLabel.numberOfLines = 0;
    [donateExplanationLabel setText:@"Donating sensor data requires your phone location.\nYour data belongs to you. At any time, you can stop collection from the phone, or delete your data from datahub, where it is stored."];
    [donateExplanationLabel setTextColor:[UIColor lightGrayColor]];
    [donateExplanationLabel setTextAlignment:NSTextAlignmentCenter];
    [donateExplanationLabel setFont:[UIFont systemFontOfSize:12]];
    [finalView addSubview:donateExplanationLabel];

    // finally make the second view the view
    self.view = finalView;
}

- (void) loadWorkingView{
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

# pragma mark - user interaction

- (void) emailButtonTouched:(id) sender{
    // will be creating an account with an email address
    randomAcct = NO;
    
    [self setTitle:@"Create an Account With Your Email"];
    
    // set the explanitory text
    [datahubAcctExplanationTextView setText:@"This will create a DataHub account using your email address.\n\nYour email and username will be visible to LivingLab researchers.\n\nLater, you will be able to log into your datahub account and edit your data."];
    
    cancelButton.hidden = NO;
    createButton.hidden = NO;
    emailTextField.hidden = NO;
    datahubAcctExplanationTextView.hidden = NO;
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        // hide the two big buttons
        anonomousButton.backgroundColor = [UIColor clearColor];
        emailButton.backgroundColor = [UIColor clearColor];
        
        // show the other stuff
        [cancelButton setBackgroundColor:[UIColor grayColor]];
        [createButton setBackgroundColor:[UIColor redColor]];
        [emailTextField setAlpha:1];
        [datahubAcctExplanationTextView setAlpha:1];
        
        [self offsetViews:@[anonomousButton, emailButton] byY:-100];
        
        
    }completion:^(BOOL done){
        //some completition
        anonomousButton.hidden = TRUE;
        emailButton.hidden = TRUE;
    }];

}

- (void) anonomousButtonTouched:(id) sender{
    // will be creating a random account
    randomAcct = YES;
    
    [self setTitle:@"Create an Anonomous Account"];
    
    // set the explanitory text
    [datahubAcctExplanationTextView setText:@"This will create a datahub account with a random username and password.\n\nYour data will be entirely anonomous.\n\nLater, you will be able to log into your datahub account and edit your data."];
    
    cancelButton.hidden = NO;
    createButton.hidden = NO;
    emailTextField.hidden = YES;
    datahubAcctExplanationTextView.hidden = NO;
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        // hide the two big buttons
        anonomousButton.backgroundColor = [UIColor clearColor];
        emailButton.backgroundColor = [UIColor clearColor];
        
        // show the other stuff
        [cancelButton setBackgroundColor:[UIColor grayColor]];
        [createButton setBackgroundColor:[UIColor redColor]];
        [datahubAcctExplanationTextView setAlpha:1];
        
        [self offsetViews:@[anonomousButton, emailButton] byY:-100];
        
        
    }completion:^(BOOL done){
        //some completition
        anonomousButton.hidden = TRUE;
        emailButton.hidden = TRUE;
    }];
}
# pragma mark

- (void) createButtonTouched:(id) sender{
    if (randomAcct) {
        // create a random account
        [self setupDataHubRandomUser];
    } else if ([self NSStringIsValidEmail:emailTextField.text])  {
        // if the email is valid, setup a new datahub user
        [self setupDataHubNewUser];
    } else {
        // the email isn't valid
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bad Email" message:@"Please check your email address and try again." delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
    }
}

- (void) cancelButtonTouched:(id) sender{
    [self setTitle:@"Please Select an Account Type"];
    anonomousButton.hidden = NO;
    emailButton.hidden = NO;
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        // show the buttons
        anonomousButton.backgroundColor = blueColor;
        emailButton.backgroundColor = greenColor;
        
        // hide the other stuff
        [cancelButton setBackgroundColor:[UIColor clearColor]];
        [createButton setBackgroundColor:[UIColor clearColor]];
        [emailTextField setAlpha:0];
//        [datahubAcctExplanationTextView setAlpha:0];
        
        [self offsetViews:@[anonomousButton, emailButton] byY:100];
        
        
    }completion:^(BOOL done){
        //some completition
        cancelButton.hidden = YES;
        createButton.hidden = YES;
        emailTextField.hidden = YES;
        [datahubAcctExplanationTextView setText:explanationText];
    }];
}

# pragma mark

-(void)offsetViews:(NSArray *)views byY:(int)yoff {
    for (UIView *v in views) {
        CGRect frame = v.frame;
        frame.origin.y += yoff;
        v.frame = frame;
    }
}

- (void) dismissKeyboard {
    [emailTextField resignFirstResponder];
}
# pragma mark

- (void) goToGetFit:(id) sender{
    // set the sensor resume date, etc
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (donateSwitch.isOn) {
        [defaults setObject:[NSDate date] forKey:@"resumeSensorDate"];
        [defaults synchronize];
        
        // initialize this here, because otherwise, significantLocationChange won't

//        [del setupLocationManager];
        
    } else {
        [defaults setObject:[NSDate distantFuture] forKey:@"resumeSensorDate"];
        [defaults synchronize];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

# pragma mark - setup
- (void) accept:(id) sender {
    [self loadChoiceView];

}

- (void) setupDataHubNewUser{
    DataHubCreation *dhCreation = [[DataHubCreation alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *password = [dhCreation createRandomAlphaNumericString];
    NSString *email = emailTextField.text;
    NSString *username = [dhCreation createUsernameFromEmail:email];
    
    NSNumber * newDataHubAcct = [dhCreation createDataHubUserFromEmail:email andUsername:username andPassword:password];
    
    if ([newDataHubAcct isEqualToNumber:@1]) {
        // user is created
        [dhCreation createSchemaForUser:username];
        [self loadFinalView];
    } else if ([newDataHubAcct isEqualToNumber:@2]){
        // duplicate user/email
        IntroAuthorizationVC *introAuth = [[IntroAuthorizationVC alloc]  init];
        introAuth.introVC = self;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:introAuth];
        navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        [self presentViewController:navController animated:YES completion:nil];
        
    } else {
        // unknown error
        
        [defaults setObject:nil forKey:@"password"];
        [defaults setObject:nil forKey:@"email"];
        [defaults setObject:nil forKey:@"username"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Creating Account" message:@"There was an error creating your account. Please try again later." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [self loadChoiceView];
        [alert show];
    }
}

- (void) setupDataHubRandomUser{
    // make a username, password, and datahub account
    // record the results
    // put them into
    DataHubCreation *dhCreation = [[DataHubCreation alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *username = [dhCreation createRandomAlphaStringOfLength:6];
    NSString *password = [dhCreation createRandomAlphaNumericString];
    NSString *email = [NSString stringWithFormat:@"albert.r.carter.mit+%@@gmail.com", username];
    
    [self loadWorkingView];
    
    
    // create the account
    NSNumber * newDataHubAcct = [dhCreation createDataHubUserFromEmail:email andUsername:username andPassword:password];
    [dhCreation createSchemaForUser:username];
    
    [defaults setObject:email forKey:@"email"];
    [defaults setObject:password forKey:@"password"];
    [defaults setObject:username forKey:@"username"];
    [defaults synchronize];
    
    
    if ([newDataHubAcct isEqualToNumber:@1]) {
        // success
        [self loadFinalView];
    } else {
        // duplicate acct, network down, or dh problems
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Creating Account" message:@"There was an error creating your account. Please try again later." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [self loadFirstView];
        [alert show];
    }

    
}

# pragma mark - helpers

-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
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
