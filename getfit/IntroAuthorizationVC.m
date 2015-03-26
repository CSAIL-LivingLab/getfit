//
//  IntroAuthorizationVC.m
//  GetFit
//
//  Created by Albert Carter on 1/18/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import "IntroAuthorizationVC.h"
#import "IntroVC.h"
#import "Secret.h"
#import "DataHubCreation.h"

@interface IntroAuthorizationVC () {
    UIWebView *myWebView;
    
    }

@end

@implementation IntroAuthorizationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"Please Authorize Getfit";
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                   style:UIBarButtonItemStylePlain target:self action:@selector(dismiss)];
    self.navigationItem.leftBarButtonItem = leftButton;
    
    [self setupWebView];
}

- (void) dismiss{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) setupWebView {
    // get appid and token
    Secret *secret = [Secret sharedSecret];
    NSString *appID = secret.DHAppID;
    
//    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:@"username"];
    
    // layout view
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    myWebView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width ,screenRect.size.height)];
    myWebView.delegate = self;
    
    // If the certs are good, go to GetFit. Otherwise, assume that the user will need to log in.
    NSString *urlStr = [NSString stringWithFormat:@"https://datahub.csail.mit.edu/permissions/apps/allow_access/%@/%@?redirect_url=https://projects.csail.mit.edu/bigdata/getfit-html/datahubThankYou.html", appID, @"getfit"];
    
    NSURL *url = [NSURL URLWithString:urlStr];
    
    NSURLRequest *request=[NSURLRequest requestWithURL:url];
    [myWebView loadRequest:request];
    
    [self.view addSubview:myWebView];
}



- (void) webViewDidFinishLoad:(UIWebView *)webView{
   
    NSString *url = [[webView.request URL] absoluteString];
    NSString *theTitle=[webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    
    
    // only two urls, the datahub one and the livinglab one
    if (![url isEqualToString:@""] && [theTitle rangeOfString:@"Thank You"].location != NSNotFound) {
        
        // make sure the continue button target changes
        DataHubCreation *dhCreation = [[DataHubCreation alloc] init];
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [dhCreation createSchemaForUser:[defaults objectForKey:@"username"]];
        
        [self.introVC loadFinalView];
        
        // then dismiss self
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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
