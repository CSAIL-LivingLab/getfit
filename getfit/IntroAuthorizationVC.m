//
//  IntroAuthorizationVC.m
//  GetFit
//
//  Created by Albert Carter on 1/18/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import "IntroAuthorizationVC.h"
#import "Secret.h"

@interface IntroAuthorizationVC () {
    UIWebView *myWebView;
    }

@end

@implementation IntroAuthorizationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"Please authorize this app on DataHub";
    [self setupWebView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupWebView {
    // get appid and token
    Secret *secret = [Secret sharedSecret];
    NSString *appID = secret.DHAppID;
    
    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    
    // layout view
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    myWebView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width ,screenRect.size.height)];
    myWebView.delegate = self;
    
    // If the certs are good, go to GetFit. Otherwise, assume that the user will need to log in.
    NSString *urlStr = [NSString stringWithFormat:@"http://datahub.csail.mit.edu/permissions/apps/allow_access/%@/%@", appID, @"getfit"];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    [myWebView loadRequest:request];
    
    [self.view addSubview:myWebView];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView{
    // if it's the auth page, prevent them from changing their username
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
