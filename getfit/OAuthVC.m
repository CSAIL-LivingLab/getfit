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
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *url = [webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
    NSLog(@"%@", url);
    // hide window
    // extract email address
    // close window
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
