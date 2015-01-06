//
//  OAuthVC.m
//  GetFit
//
//  Created by Albert Carter on 12/5/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import "OAuthVC.h"

@interface OAuthVC ()

@end

@implementation OAuthVC {
    UIWebView *webView;
    NSString *urlStr;
    NSString *email;
    NSString *token;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // make a bar button
    [self makeDoneButton];
    [self makeScrapeButton];
    
    // prep the url
    [self prepUrl];
    
    // make the web view load
    [self setupWebView];
}


- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) makeDoneButton {
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                    style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    self.navigationItem.rightBarButtonItem = rightButton;
}

- (void) makeScrapeButton {
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Scrape"
                                                                   style:UIBarButtonSystemItemAction target:self action:@selector(scrape)];
    self.navigationItem.leftBarButtonItem = leftButton;
}

- (void) setupWebView {
    // layout view
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    webView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width ,screenRect.size.height)];
    webView.delegate = self;
    
    // load url
    NSURL *nsurl=[NSURL URLWithString:urlStr];
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [webView loadRequest:nsrequest];
    [self.view addSubview:webView];

}

- (void) prepUrl{
    // this method exists because I may need to do some more compliated things with urls alter.
    urlStr = @"https://getfit-d7-dev.mit.edu/Shibboleth.sso/Login?target=https%3A%2F%2Fgetfit-d7-dev.mit.edu%2F%3Fq%3Dshib_login%2Ffront-page";
}

// extract email address
// extract tokens

- (void) scrape {
    NSString *url = [webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
    
    if ([url rangeOfString:@"profile"].location != NSNotFound) {
        [self extractEmail];
    } else if ([url rangeOfString:@"dashboard"].location != NSNotFound) {
        [self extractTokens];
    }

}

- (void) extractEmail {
    NSLog(@"extract Email hit");
    
    NSString * jsCallBack = [NSString stringWithFormat:@"document.getElementById(\"edit-mail\").value"];
    email = [webView stringByEvaluatingJavaScriptFromString:jsCallBack];
    NSLog(@"%@", email);
    
    
}

- (void) extractTokens {
    NSLog(@"extract tokens hit");
    
    NSString * tokenStr = [webView stringByEvaluatingJavaScriptFromString:@"var index; var arr = document.getElementsByName('form_id'); for (var i = 0; i < arr.length; i++) {    if ('getfit_minutes_single_form_2' == arr[i].value) {        index = i;    };} var form_token = document.getElementsByName('form_token')[index].value; var form_build_id = document.getElementsByName('form_build_id')[index].value; var form_id = 'getfit_minutes_single_form_2'; function foo() { return form_token+','+form_build_id+','+form_id; } foo();"];
    
    // parse tokens
    NSArray *tokens = [tokenStr componentsSeparatedByString:@","];
    
    NSString *form_token = tokens[0];
    NSString *form_build_id = tokens[1];
    NSString *form_id = tokens[2];
    
    
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *url = [webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
//    [self scrape];
    // hide window
    // extract email address
    // close window
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
