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

# pragma mark - navigation
- (void) makeSchemaAndPushNextVC{
    // method for IntroAuthorizationVC to access
//    [self setupDataHubSchema];
    [self.introPageVC pushDetailVC];
}

- (IBAction)tapToContinue:(id)sender {
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

@end
