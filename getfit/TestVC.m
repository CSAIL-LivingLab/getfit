//
//  TestVC.m
//  GetFit
//
//  Created by Albert Carter on 1/12/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//
// file is used to test code that will be used for [MinuteStore postToGetFit];


#import "TestVC.h"
#import "MinuteStore.h"
#import "Secret.h"
#import "MinuteEntry.h"
#import "OAuthVC.h"

@interface TestVC ()

@end

@implementation TestVC


- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"testing";
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)postToGetFit:(id)sender {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-DD"];

    // create the entry and format somet hings
    MinuteEntry *me = [[MinuteEntry alloc] initEntryWithActivity:@"WORK_AGAIN_4" intensity:@"high" duration:200 andEndTime:[NSDate date]];
    NSString *endDate = [dateFormatter stringFromDate:me.endTime];
    NSString *duration = [NSString stringWithFormat: @"%ld", (long)me.duration];
    
    // get the form info
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *form_token = [defaults objectForKey:@"form_token"];
    NSString *form_build_id = [defaults objectForKey:@"form_build_id"];
    NSString *form_id = [defaults objectForKey:@"form_id"];

    // gather the cookies
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray * cookies  = [cookieJar cookies];
    NSDictionary * headers = [NSHTTPCookie requestHeaderFieldsWithCookies:cookies];
    
    // format the post body
    NSString *post = [NSString stringWithFormat:@"&form_token=%@&form_build_id=%@&form_id=%@&activity=%@&intensity=%@&date=%@&duration=%@", form_token, form_build_id, form_id, me.activity, me.intensity, endDate, duration];
    post = [post stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    // format the request
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: [NSURL URLWithString:@"https://getfit-d7-dev.mit.edu/system/ajax"]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [request setAllHTTPHeaderFields:headers];
    [request setHTTPBody:postData];
    
    NSURLResponse *response;
    NSError *error;
    
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    NSLog(@"\n\nhttpResponse:\n %@", [httpResponse allHeaderFields]);
}

- (IBAction)loadOAuthVC:(id)sender {
    OAuthVC *oAuthVC = [[OAuthVC alloc]  init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:oAuthVC];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)cookieMonster:(id)sender {
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    NSArray * cookies  = [cookieJar cookies];
    NSHTTPCookie *cookie;
    
    for (int i = 0; i< [cookies count]; i++) {
        cookie = [cookies objectAtIndex:i];
        NSLog(@"\n\nCOOKIE:  %@", cookie);
        NSLog(@"\nEXPIRATION DATE: %@", cookie.expiresDate);
        
        if ([cookie.name rangeOfString:@"SSESS"].location != NSNotFound ) {
            
            if ([[NSDate date] compare:cookie.expiresDate] == NSOrderedAscending) {
                NSLog(@"cookie is valid");
            } else {
                NSLog(@"cookie not valid");
            }
            
            break;
        }
    }
    
    
}

@end
