//
//  IntroVC.m
//  GetFit
//
//  Created by Albert Carter on 1/28/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import "IntroVC.h"

#import <QuartzCore/QuartzCore.h>
#include<unistd.h>
#include<netdb.h>

#import "IntroAuthorizationVC.h"
#import "DataHubCreation.h"
#import "LocationObject.h"


@interface IntroVC ()

@end

@implementation IntroVC {
    UIColor *blueColor;
    UIColor *greenColor;
    CGSize bounds;
    BOOL *randomAcct;
    CLLocationManager *locManager;
    
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
    UIButton *randomUsernameButton;
    UIButton *emailUsernameButton;
    UITextField *emailTextField;
    UITextView *datahubAcctExplanationTextView;
    NSString *explanationText;
    UIButton *cancelButton;
    UIButton *createButton;
    
    // final view
    UIView *finalView;
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
//    [self loadFinalView];
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
    NSURL *url = [NSURL URLWithString:@"https://projects.csail.mit.edu/bigdata/getfit-html/consent.html"];
    NSString *htmlString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    NSData *htmlData = [htmlString dataUsingEncoding:NSUnicodeStringEncoding];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:htmlData options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    legalText = [[UITextView alloc] initWithFrame:CGRectMake(8, 70, bounds.width-16, bounds.height-70)];
    legalText.editable = NO;
    legalText.attributedText = attributedString;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [legalText setBackgroundColor:[UIColor clearColor]];
    [legalText setTextColor:[UIColor whiteColor]];
    [legalText setDelegate:self];
    [firstView addSubview:legalText];
    
    CGFloat legalTextOffset = legalText.frame.size.height + legalText.frame.origin.y;
    
    // accept button
    acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(bounds.width/2-40, bounds.height - 80, 80, 80)];
    acceptButton.layer.cornerRadius = acceptButton.bounds.size.width/2;
    [acceptButton setTitle:@"scroll\ndown" forState:UIControlStateNormal];
    [acceptButton.titleLabel setNumberOfLines:0];
    acceptButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    acceptButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [acceptButton.layer setBackgroundColor:[blueColor CGColor]];
    acceptButton.userInteractionEnabled = NO;
    acceptButton.alpha = .8;
    
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
    [self setTitle:@"Choose DataHub Account Option"];
    choiceView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.width, bounds.height)];
    [choiceView setBackgroundColor:[UIColor blackColor]];
    
    CGFloat largeButtonWidth = 140;
    CGFloat smallButtonWidth = 140;
    
    CGFloat buttonOffsetY = bounds.height/2-largeButtonWidth/2;
    CGFloat fieldsOffsetY = 100;
    
    // select random username
    randomUsernameButton = [[UIButton alloc] initWithFrame:CGRectMake(10, buttonOffsetY, largeButtonWidth, largeButtonWidth)];
    randomUsernameButton.layer.cornerRadius = largeButtonWidth/2;
    randomUsernameButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    randomUsernameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [randomUsernameButton setBackgroundColor:blueColor];
    [randomUsernameButton setTitle:@"Assign me\na random\nusername" forState:UIControlStateNormal];
    [randomUsernameButton.titleLabel setNumberOfLines:0];
    [randomUsernameButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [randomUsernameButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [randomUsernameButton addTarget:self action:@selector(randomButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [choiceView addSubview:randomUsernameButton];
    
    // select account using email
    emailUsernameButton = [[UIButton alloc] initWithFrame:CGRectMake(bounds.width-10-largeButtonWidth, buttonOffsetY, largeButtonWidth, largeButtonWidth)];
    emailUsernameButton.layer.cornerRadius = largeButtonWidth/2;
    emailUsernameButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    emailUsernameButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [emailUsernameButton setBackgroundColor:greenColor];
    [emailUsernameButton setTitle:@"I'll use my\nemail as my\nusername" forState:UIControlStateNormal];
    [emailUsernameButton.titleLabel setNumberOfLines:0];
    [emailUsernameButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [emailUsernameButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [emailUsernameButton addTarget:self action:@selector(emailButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [choiceView addSubview:emailUsernameButton];

    /* Fields that will appear after tapping one of the above buttons. 
     These start as hidden with clearColor or alpha = 0 */

    
    // field that email goes into
    emailTextField = [[UITextField alloc] initWithFrame:CGRectMake(15, fieldsOffsetY, bounds.width - 30, 40)];
    emailTextField.hidden = YES;
//    [emailTextField setTextColor:[UIColor clearColor]];
    emailTextField.alpha = 0;
    [emailTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    [emailTextField setBorderStyle:UITextBorderStyleRoundedRect];
    [emailTextField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [emailTextField setBackgroundColor:[UIColor colorWithRed:0.173 green:0.243 blue:0.314 alpha:1]];
    [emailTextField setTextAlignment:NSTextAlignmentCenter];
    [emailTextField setClearButtonMode:UITextFieldViewModeWhileEditing];
    [emailTextField setTextColor:[UIColor whiteColor]];
    // border
    emailTextField.layer.cornerRadius=8.0f;
    emailTextField.layer.masksToBounds=YES;
    emailTextField.layer.borderColor=[blueColor CGColor];
    emailTextField.layer.borderWidth= 1.5f;
    emailTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"your email" attributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
    
    
    
    [choiceView addSubview:emailTextField];
    
    // dismiss the keybord on tap background
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [tapBackground setNumberOfTapsRequired:1];
    [choiceView addGestureRecognizer:tapBackground];

    CGFloat emailTextFieldOffset = emailTextField.frame.origin.y + emailTextField.frame.size.height;
    
    cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(10, emailTextFieldOffset + 50, smallButtonWidth, smallButtonWidth)];
    cancelButton.layer.cornerRadius = smallButtonWidth/2;
    cancelButton.hidden = YES;
    cancelButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    cancelButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [cancelButton setBackgroundColor:[UIColor clearColor]];
    [cancelButton setTitle:@"cancel" forState:UIControlStateNormal];
    [cancelButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [cancelButton addTarget:self action:@selector(cancelButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [choiceView addSubview:cancelButton];

    
    createButton = [[UIButton alloc] initWithFrame:CGRectMake(bounds.width - 10 - smallButtonWidth, emailTextFieldOffset + 50, smallButtonWidth, smallButtonWidth)];
    createButton.layer.cornerRadius = smallButtonWidth/2;
    createButton.hidden = YES;
    createButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    createButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [createButton setBackgroundColor:[UIColor clearColor]];
    [createButton setTitle:@"create" forState:UIControlStateNormal];
    [createButton.titleLabel setFont:[UIFont systemFontOfSize:20]];
    [createButton addTarget:self action:@selector(createButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [choiceView addSubview:createButton];

    // explanation of account type
    explanationText = @"";
    datahubAcctExplanationTextView = [[UITextView alloc] initWithFrame:CGRectMake(8, bounds.height-170, bounds.width-16, 170)];
    datahubAcctExplanationTextView.hidden = NO;
    datahubAcctExplanationTextView.alpha = 1;
    [datahubAcctExplanationTextView setText:explanationText];
    [datahubAcctExplanationTextView setTextAlignment:NSTextAlignmentCenter];
    [datahubAcctExplanationTextView setFont:[UIFont systemFontOfSize:15]];
    [datahubAcctExplanationTextView setBackgroundColor:[UIColor clearColor]];
    [datahubAcctExplanationTextView setTextColor:[UIColor whiteColor]];
    [choiceView addSubview:datahubAcctExplanationTextView];
  
    [self fadeInNewView:choiceView];
}

- (void) loadFinalView{
    [self setTitle:@"You're Done With Set Up!"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults objectForKey:@"username"];
    NSString *password = [defaults objectForKey:@"password"];
    
    // view
    finalView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.width, bounds.height)];
    [finalView setBackgroundColor:[UIColor blackColor]];
    
    // setup label
    setupLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 75, bounds.width-16, 60)];
    setupLabel.numberOfLines = 0;
    [setupLabel setText:@"We've set up your GetFit DataHub account:"];
    [setupLabel setTextColor:[UIColor whiteColor]];
    [setupLabel setTextAlignment:NSTextAlignmentCenter];
    [finalView addSubview:setupLabel];
    
    CGFloat topLabelOffset = setupLabel.frame.origin.y + setupLabel.frame.size.height;
    
    // username/password info labels
    usernameInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(bounds.width/2-75, topLabelOffset +8, 70, 15)];
    [usernameInfoLabel setTextColor:[UIColor whiteColor]];
    [usernameInfoLabel setTextAlignment:NSTextAlignmentRight];
    [usernameInfoLabel setFont:[UIFont systemFontOfSize:14]];
    [usernameInfoLabel setText:@"username:"];
    [finalView addSubview:usernameInfoLabel];
    
    passwordInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(bounds.width/2-75, topLabelOffset +8 +20, 70, 15)];
    [passwordInfoLabel setTextColor:[UIColor whiteColor]];
    [passwordInfoLabel setTextAlignment:NSTextAlignmentRight];
    [passwordInfoLabel setFont:[UIFont systemFontOfSize:14]];
    [passwordInfoLabel setText:@"password:"];
    [finalView addSubview:passwordInfoLabel];

    // actual username and password
    usernameLabel = [[UILabel alloc] initWithFrame:CGRectMake(bounds.width/2 +5, topLabelOffset + 8, 150, 15)];
    [usernameLabel setTextColor:[UIColor whiteColor]];
    [usernameLabel setTextAlignment:NSTextAlignmentLeft];
    [usernameLabel setFont:[UIFont systemFontOfSize:14]];
    [usernameLabel setText:username];
//    [usernameLabel setText:@"bdoijewf"];
    [finalView addSubview:usernameLabel];

    passwordLabel = [[UILabel alloc] initWithFrame:CGRectMake(bounds.width/2 +5, topLabelOffset + 8 +20, 150, 15)];
    [passwordLabel setTextColor:[UIColor whiteColor]];
    [passwordLabel setTextAlignment:NSTextAlignmentLeft];
    [passwordLabel setFont:[UIFont systemFontOfSize:14]];
        [passwordLabel setText:password];
//    [passwordLabel setText:@"bdoijewf"];
    [finalView addSubview:passwordLabel];
    
    
    // explanationlabel
    explanationView = [[UITextView alloc] initWithFrame:CGRectMake(8, passwordLabel.frame.origin.y + 15, bounds.width-16, 140)];
    [explanationView setFont:[UIFont systemFontOfSize:14]];
    [explanationView setText:@"Use it to view your data at\nhttps://www.datahub.csail.mit.edu\n\nYou can view your username and password from this app, but you may also want to write them down."];
    [explanationView setTextColor:[UIColor whiteColor]];
    [explanationView setBackgroundColor:[UIColor clearColor]];
    [explanationView setEditable:NO];
    [explanationView setScrollEnabled:NO];
    [explanationView setTextAlignment:NSTextAlignmentCenter];
    [explanationView setDataDetectorTypes:UIDataDetectorTypeAll];
    [explanationView sizeToFit];
    [finalView addSubview:explanationView];
    
    CGFloat explanationOffset =explanationView.frame.origin.y + explanationView.frame.size.height;
    
    // button
    goToGetFit = [[UIButton alloc] initWithFrame:CGRectMake(bounds.width/2-65, explanationOffset + 10, 130, 130)];
    goToGetFit.layer.cornerRadius = goToGetFit.bounds.size.width/2;
    [goToGetFit.layer setBackgroundColor:[blueColor CGColor]];
    [goToGetFit setTitle:@"Start Getting Fit" forState:UIControlStateNormal];
    [goToGetFit.titleLabel setFont:[UIFont systemFontOfSize:15]];
    [goToGetFit.titleLabel setNumberOfLines:0];
    goToGetFit.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    goToGetFit.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    
    
    [goToGetFit setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [goToGetFit addTarget:self action:@selector(goToGetFit:) forControlEvents:UIControlEventTouchUpInside];
    [finalView addSubview:goToGetFit];
    
    // donate things are bottom alligned
    donateSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(30, bounds.height - 100, 60, 40)];
    donateSwitch.on = YES;
    [finalView addSubview:donateSwitch];
    
    donateSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(90, bounds.height - 105 , 330, 40)];
    [donateSwitchLabel setText:@"Allow Sensor Data Collection"];
    [donateSwitchLabel setTextColor:[UIColor whiteColor]];
    [donateSwitchLabel setFont:[UIFont systemFontOfSize:15]];
    [finalView addSubview:donateSwitchLabel];
    
    donateExplanationLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, bounds.height - 65, bounds.width-16, 60)];
    donateExplanationLabel.numberOfLines = 0;
    [donateExplanationLabel setText:@"Allowing sensor data collection requires your phone location. Your data belongs to you. At any time, you can stop collection from the phone, or delete your data from datahub, where it is stored."];
    [donateExplanationLabel setTextColor:[UIColor lightGrayColor]];
    [donateExplanationLabel setTextAlignment:NSTextAlignmentCenter];
    [donateExplanationLabel setFont:[UIFont systemFontOfSize:12]];
    [finalView addSubview:donateExplanationLabel];

    // finally make the second view the view
    [self fadeInNewView:finalView];
}

- (void) loadWorkingView{
    workingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.width, bounds.height)];
    [workingView setBackgroundColor:[UIColor blackColor]];
    
    workingLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, bounds.height/2-30, bounds.width-16, 60)];
    workingLabel.numberOfLines = 0;
    [workingLabel setText:@"Setting up your DataHub account."];
    [workingLabel setTextColor:[UIColor lightGrayColor]];
    [workingLabel setTextAlignment:NSTextAlignmentCenter];
    [workingView addSubview:workingLabel];
    
    workingSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(bounds.width/2-30, bounds.height/2+30, 60, 60)];
    workingSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [workingSpinner startAnimating];
    [workingView addSubview:workingSpinner];
    
    [self fadeInNewView:workingView];
}

# pragma mark - user interaction

- (void) emailButtonTouched:(id) sender{
    // will be creating an account with an email address
    randomAcct = NO;
    
    [self setTitle:@"DataHub with Email as Username"];
    
    // set the explanitory text
    [datahubAcctExplanationTextView setText:@"Chosing \"create\" will create a DataHub account using your email address as your username and a random password.\n\nYour email address will be visible to DataHub associated researchers."];
    
    cancelButton.hidden = NO;
    createButton.hidden = NO;
    emailTextField.hidden = NO;
    datahubAcctExplanationTextView.hidden = NO;
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        // hide the two big buttons
        randomUsernameButton.backgroundColor = [UIColor clearColor];
        emailUsernameButton.backgroundColor = [UIColor clearColor];
        
        // show the other stuff
        [cancelButton setBackgroundColor:[UIColor grayColor]];
        [createButton setBackgroundColor:[UIColor redColor]];
        [emailTextField setAlpha:1];
        [datahubAcctExplanationTextView setAlpha:1];
        
        [self offsetViews:@[randomUsernameButton, emailUsernameButton] byY:-100];
        
        
    }completion:^(BOOL done){
        //some completition
        randomUsernameButton.hidden = TRUE;
        emailUsernameButton.hidden = TRUE;
    }];

}

- (void) randomButtonTouched:(id) sender{
    // will be creating a random account
    randomAcct = YES;
    
    [self setTitle:@"DataHub With Random Username"];
    
    // set the explanitory text
    [datahubAcctExplanationTextView setText:@"Chosing \"create\" will create a DataHub account with a random username and password.\n\nYour data will be entirely anonymous, and DataHub associated researchers will be unable to provide tech support."];
    
    cancelButton.hidden = NO;
    createButton.hidden = NO;
    emailTextField.hidden = YES;
    datahubAcctExplanationTextView.hidden = NO;
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        // hide the two big buttons
        randomUsernameButton.backgroundColor = [UIColor clearColor];
        emailUsernameButton.backgroundColor = [UIColor clearColor];
        
        // show the other stuff
        [cancelButton setBackgroundColor:[UIColor grayColor]];
        [createButton setBackgroundColor:[UIColor redColor]];
        [datahubAcctExplanationTextView setAlpha:1];
        
        [self offsetViews:@[randomUsernameButton, emailUsernameButton] byY:-100];
        
        
    }completion:^(BOOL done){
        //some completition
        randomUsernameButton.hidden = TRUE;
        emailUsernameButton.hidden = TRUE;
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
    [self setTitle:@"Choose DataHub Account Option"];
    randomUsernameButton.hidden = NO;
    emailUsernameButton.hidden = NO;
    
    [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        // show the buttons
        randomUsernameButton.backgroundColor = blueColor;
        emailUsernameButton.backgroundColor = greenColor;
        
        // hide the other stuff
        [cancelButton setBackgroundColor:[UIColor clearColor]];
        [createButton setBackgroundColor:[UIColor clearColor]];
        [emailTextField setAlpha:0];
//        [datahubAcctExplanationTextView setAlpha:0];
        
        [self offsetViews:@[randomUsernameButton, emailUsernameButton] byY:100];
        
        
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
    
    if (donateSwitch.isOn && [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        // synchronize defaults and request permission,
        // which will dismiss the VC itself.
        [defaults setObject:[NSDate date] forKey:@"resumeSensorDate"];
        [defaults synchronize];
        [self requestLocPermissions];
        
    } else if (donateSwitch.isOn){
        // just synchronize defaults and dismiss
        [defaults setObject:[NSDate date] forKey:@"resumeSensorDate"];
        [defaults synchronize];
        [self dismissViewControllerAnimated:YES completion:nil];
        
    } else {
        // synchronize defaults and dismiss
        [defaults setObject:[NSDate distantFuture] forKey:@"resumeSensorDate"];
        [defaults synchronize];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

# pragma mark - setup
- (void) accept:(id) sender {
    [self loadChoiceView];
}

- (void) setupDataHubNewUser{
    DataHubCreation *dhCreation = [[DataHubCreation alloc] init];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSString *password = [dhCreation createRandomAlphaNumericString];
    NSString *email = [emailTextField.text lowercaseString];
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

- (void) fadeInNewView:(UIView *) newView{
    // fade a new view in from an old one
    
    // take a picture of the old view
    CGRect rect = [self.view bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // add the picture the top of the new view
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    [imageView setImage:capturedImage];
    [newView addSubview:imageView];
    
    // make the new view the root view
    [self setView:newView];
    
    // fade out the image
    [UIView animateWithDuration:0.7 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        [imageView setAlpha:0];
        
    }completion:^(BOOL done){
        // remove it from superview to avoid memory leaks
        imageView.hidden = YES;
        [imageView removeFromSuperview];
    }];
}

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
# pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // if this is the legal text, show the acceptButton
    
    if (scrollView == legalText) {
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            
            [acceptButton setAlpha:1];
            
        }completion:^(BOOL done){
            [acceptButton setTitle:@"I Accept" forState:UIControlStateNormal];
            acceptButton.userInteractionEnabled = YES;
        }];
    }
}

# pragma mark - CLLocationManagerDelegate

-(void)requestLocPermissions {
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        locManager = [[CLLocationManager alloc] init];
        locManager.delegate = self;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        int authStatus = [CLLocationManager authorizationStatus];
//        NSLog(@"authStatus = %d", authStatus);
        if (authStatus == kCLAuthorizationStatusNotDetermined && floor(kCFCoreFoundationVersionNumber) > kCFCoreFoundationVersionNumber_iOS_7_1) {
            [locManager requestAlwaysAuthorization];
        } else
#endif
        [locManager startMonitoringSignificantLocationChanges];
    }
}


- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
    // if the status is determined
    // stop location tracking from the IntroVC
    // start using the locationObject
    // dismiss the view controller
    if (status!=kCLAuthorizationStatusNotDetermined) {
        [manager stopMonitoringSignificantLocationChanges];
        [[LocationObject sharedLocationObject] setupLocationManager];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
}

@end
