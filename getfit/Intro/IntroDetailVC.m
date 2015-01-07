//
//  IntroDetailVC.m
//  GetFit
//
//  Created by Albert Carter on 1/6/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import "IntroDetailVC.h"
#import "Secret.h"
#import "IntroPageVC.h"

#import "datahub.h"
#import "account.h"
#import <THTTPClient.h>
#import <TBinaryProtocol.h>

@interface IntroDetailVC ()

@end

@implementation IntroDetailVC
@synthesize thankYouLabel, setUpLabel, usernameStrLabel, passwordStrLabel, usernameLabel, passwordLabel, detailTextArea, spinnerIndicator, setupLabel, getfitButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    getfitButton.hidden = YES;
    
    // show spinny thing, and setup up
    [self setUpDataHub]; //shows other things once it's done

    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(save)];
    self.navigationItem.rightBarButtonItem = rightButton;
    
    
}

- (void) setUpDataHub {

    // app tokens
    @try {
        Secret *secret = [Secret sharedSecret];
        NSString * appID = [secret DHAppID];
//        NSString * appName = [secret DHAppName];
        NSString * appToken = [secret DHAppToken];
        
        // username and password
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[self createPassword] forKey:@"password"];
        [defaults setObject:[self createUsername] forKey:@"username"];
        [defaults synchronize];
        
        NSString *email = [defaults objectForKey:@"email"];
        NSString *username = [defaults objectForKey:@"username"];
        NSString *password = [defaults objectForKey:@"password"];
        
        // setup for DH accountClient
        NSURL *url = [NSURL URLWithString:@"https://datahub.csail.mit.edu/service/account"];
        THTTPClient *transport = [[THTTPClient alloc] initWithURL:url];
        TBinaryProtocol *protocol = [[TBinaryProtocol alloc]
                                     initWithTransport:transport
                                     strictRead:YES
                                     strictWrite:YES];
        datahub_accountAccountServiceClient *accountClient = [[datahub_accountAccountServiceClient alloc] initWithProtocol:protocol];
        
        [accountClient create_account:username email:email password:password app_id:appID app_token:appToken];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"There was an error" message:@"please check your network connection" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles:nil];
        [alert show];
    }
    @finally {
         [self showResults];
    }
    

   
}
    // add a random string after the user's email, reducing collision risk.
- (NSString *) createUsername {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [defaults objectForKey:@"email"];
    
    // strip the email of its extra characters
    NSRange range = [email rangeOfString:@"@"];
    email = [email substringToIndex:range.location];
    
    // create the string to append
    NSString *letters = @"abcdefghijklmnopqrstuvwxyz";
    int len = 4;
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((uint32_t)[letters length])]];
    }
    
    // append the string
    NSString *username = [NSString stringWithFormat:@"%@_%@", email, randomString];
    return username;
}

- (NSString *) createPassword {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    int len = 8;
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
        
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((uint32_t)[letters length])]];
    }
    return randomString;
    
}

- (void) showResults {
    // hide setup stuff
    spinnerIndicator.hidden = YES;
    setupLabel.hidden = YES;
    
    // show new stuff
    thankYouLabel.hidden = NO;
    usernameStrLabel.hidden = NO;
    passwordStrLabel.hidden = NO;
    usernameLabel.hidden = NO;
    passwordLabel.hidden = NO;
    detailTextArea.hidden = NO;
    getfitButton.hidden = NO;
    
    
    detailTextArea.text = @"Use it to view your data at \nhttps://datahub.csail.mit.edu.\n\nThere's no need to write it down. You can access it anytime from this app, or reset it online.";
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    usernameLabel.text = [defaults objectForKey:@"username"];
    passwordLabel.text = [defaults objectForKey:@"password"];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)getfitButtonClick:(id)sender {
    NSLog(@"getFitButtonClicked");
    
    IntroPageVC *introPageVC = self.parentViewController;
    [introPageVC foo];
    [introPageVC dismissViewControllerAnimated:YES completion:nil];
    
    
}
@end
