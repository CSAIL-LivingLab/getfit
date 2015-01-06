//
//  OAuthVC.m
//  GetFit
//
//  Created by Albert Carter on 12/5/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import "OAuthVC.h"
#import "MinuteStore.h"

@interface OAuthVC ()

@end

@implementation OAuthVC {
    UIWebView *myWebView;
    NSString *email;
    NSString *token;
    NSUserDefaults *defaults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // make a bar button
    [self makeDoneButton];
    
    // make the web view load
    [self setupWebView];
    
    // prep defaults
    defaults = [NSUserDefaults standardUserDefaults];
    
}


- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) makeDoneButton {
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void) setupWebView {
    // layout view
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    myWebView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width ,screenRect.size.height)];
    myWebView.delegate = self;
    
    // load url
    NSURL *nsurl=[NSURL URLWithString:@"https://getfit-d7-dev.mit.edu/Shibboleth.sso/Login?target=https%3A%2F%2Fgetfit-d7-dev.mit.edu%2F%3Fq%3Dshib_login%2Ffront-page"];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [myWebView loadRequest:nsrequest];
    [self.view addSubview:myWebView];

}

- (void) extractEmail {
    NSLog(@"extract Email hit");
    
    NSString * jsCallBack = [NSString stringWithFormat:@"document.getElementById(\"edit-mail\").value"];
    email = [myWebView stringByEvaluatingJavaScriptFromString:jsCallBack];
    [defaults setObject:email forKey:@"email"];
    
    // to be handled elsewhere eventually.
    MinuteStore *ms = [MinuteStore sharedStore];
    [ms postToGetFit];
    
    [self dismiss];
}

- (void) extractTokens {
    NSLog(@"extract tokens hit");
    
    NSString * tokenStr = [myWebView stringByEvaluatingJavaScriptFromString:@"var index; var arr = document.getElementsByName('form_id'); for (var i = 0; i < arr.length; i++) {    if ('getfit_minutes_single_form_2' == arr[i].value) {        index = i;    };} var form_token = document.getElementsByName('form_token')[index].value; var form_build_id = document.getElementsByName('form_build_id')[index].value; var form_id = 'getfit_minutes_single_form_2'; function foo() { return form_token+','+form_build_id+','+form_id; } foo();"];
    
    // parse tokens
    NSArray *tokens = [tokenStr componentsSeparatedByString:@","];
    NSString *form_token = tokens[0];
    NSString *form_build_id = tokens[1];
    NSString *form_id = tokens[2];
    
    // set save as defaults.
    [defaults setObject:form_token forKey:@"form_token"];
    [defaults setObject:form_build_id forKey:@"form_build_id"];
    [defaults setObject:form_id forKey:@"form_id"];
    
    // once tokens are extracted, extrac the user email
    NSURL *profileURL =[NSURL URLWithString:@"https://getfit-d7-dev.mit.edu/profile"];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:profileURL];
    [myWebView loadRequest:nsrequest];
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *url = [webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
    NSLog(@"------\n%@\n------", url);
    
    // do nothing unless it's a getfit url
    if ([url rangeOfString:@"getfit"].location == NSNotFound || [url rangeOfString:@"idp.mit.edu"].location != NSNotFound) {
        return;
    }
    
    // should hide the webView and do this all automatically.
    if ([url rangeOfString:@"profile"].location != NSNotFound) {
        [self extractEmail];
    } else if ([url rangeOfString:@"dashboard"].location != NSNotFound) {
        [self extractTokens];
    }



    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
