//
//  IntroDetailVC.m
//  GetFit
//
//  Created by Albert Carter on 1/6/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import "IntroDetailVC.h"
#import "Secret.h"
#import "DataHubCreation.h"
#import "IntroPageVC.h"

#import "datahub.h"
#import "account.h"
#import <THTTPClient.h>
#import <TBinaryProtocol.h>

#import "Resources.h"

@interface IntroDetailVC ()
@property NSString * appID;
@property NSString *appToken;
@property NSString *username;
@property NSString *password;
@property NSString *email;


@end

@implementation IntroDetailVC
@synthesize usernameLabel, passwordLabel, detailTextArea, getfitButton, appID, appToken, username, password, email;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    Secret *secret = [Secret sharedSecret];
    appID = [secret DHAppID];
    appToken = [secret DHAppToken];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    email = [defaults objectForKey:@"email"];
    username = [defaults objectForKey:@"username"];
    password = [defaults objectForKey:@"password"];
    
    
    // show spinny thing, and setup up
//    [self setUpDataHub]; //shows other things once it's done

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    [self showResults];

    
}


- (void) showResults {
    
    // show new stuff
    detailTextArea.text = @"Use it to view your data at \nhttps://datahub.csail.mit.edu.\n\nThere's no need to write it down. You can access it anytime from this app, or reset it online.";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    usernameLabel.text = [defaults objectForKey:@"username"];
    passwordLabel.text = [defaults objectForKey:@"password"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getfitButtonClick:(id)sender {
    NSLog(@"getFitButtonClicked");
    
    UIViewController *introPageVC = self.parentViewController;
    [introPageVC dismissViewControllerAnimated:YES completion:nil];
    
    
}
@end
