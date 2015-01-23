//
//  IntroAboutVC.m
//  GetFit
//
//  Created by Albert Carter on 1/6/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import "IntroAboutVC_deprecated.h"
#import "IntroPageVC.h"
#import "IntroAuthorizationVC.h"
#import "DataHubCreation.h"

@interface IntroAboutVC_deprecated ()
@property (weak, nonatomic) IntroPageVC *introPageVC;
@property BOOL ready;
@end

@implementation IntroAboutVC_deprecated
@synthesize emailTextField, ready, introPageVC, tapToContinue;

// hack so that it's possible to access the parent PageVC's array of pages

- (instancetype) initWithParentPageVC: (IntroPageVC *)parentPageVC {
    self = [super init];
    if (self) {
        self.introPageVC = parentPageVC;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    tapToContinue.hidden = NO;
    
    [emailTextField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];

    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
    
}

- (void) makeSchemaAndPushNextVC{
    // method for IntroAuthorizationVC to access
    [self setupDataHubSchema];
    [self.introPageVC pushDetailVC];
}


- (IBAction)tapToContinue:(id)sender {
    [self setUpDataHubAccount];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - datahubsetup
- (void) setUpDataHubAccount {
    // username and password
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    DataHubCreation *dhCreation = [[DataHubCreation alloc] init];
    
    NSString *email = [defaults objectForKey:@"email"];
    NSString *password = [dhCreation createRandomAlphaNumericString];
    
    // use the createPassword line, since we're just generating a string, anyhow.
    NSString *username = [dhCreation createRandomAlphaNumericString];
    
    [defaults setObject:password forKey:@"password"];
    [defaults setObject:username forKey:@"username"];
    
    [defaults synchronize];
    
    // check for duplicate usernames/emails/previous authorization
    // this may overwrite email/password/username if there are duplicates
    NSNumber * newDataHubAcct = [dhCreation createDataHubUserFromEmail:email andUsername:username andPassword:password];
    
    if ([newDataHubAcct isEqualToNumber:@1]) {
        [self setupDataHubSchema];
        [introPageVC pushDetailVC];
    } else if ([newDataHubAcct isEqualToNumber:@2]){
        NSLog(@"duplicate user/email");
        
        IntroAuthorizationVC *introAuth = [[IntroAuthorizationVC alloc]  init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:introAuth];
        navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        introAuth.introAboutVC = self;
        
        [self presentViewController:navController animated:YES completion:nil];
        
    } else {
        [defaults setObject:nil forKey:@"password"];
        [defaults setObject:nil forKey:@"email"];
        [defaults setObject:nil forKey:@"username"];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"There was an unknown error creating your account. It was likely network related. Please try again later." delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
    }
}

- (void) setupDataHubSchema{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    DataHubCreation *dhCreation = [[DataHubCreation alloc] init];
    NSString *username = [defaults objectForKey:@"username"];
    
    @try {
        [dhCreation createSchemaForUser:username];
    }
    @catch (NSException *exception) {
        NSLog(@"\n\nException: %@", exception);
    }
}


#pragma mark - helpers


// should check for MIT email addresses.
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark - change 

// fade in swipe button. Save user defaults accordingly.
- (void) textChanged:(UITextField *)textField{
    // save defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:emailTextField.text forKey:@"email"];
    [defaults synchronize];
}

#pragma mark - keyboard hiding/showing

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [self animateTextField:textField up:YES];
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    [self animateTextField:textField up:NO];
}

- (void) animateTextField: (UITextField *) textField up:(BOOL)up {
    const int movementDistance = 205; // try to match keyboard size
    const float movementDuration = 0.3f; // speed of movement
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)dismissKeyboard {
    [emailTextField resignFirstResponder];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
