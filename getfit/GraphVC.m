//
//  GraphVC.m
//  GetFit
//
//  Created by Albert Carter on 12/17/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import "GraphVC.h"

#include<unistd.h>
#include<netdb.h>

#import "Resources.h"
#import "Secret.h"

@interface GraphVC ()

@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) NSString *script;
@end

@implementation GraphVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"Progress";
                UIImage *image = [UIImage imageNamed:@"chart.png"];
                self.tabBarItem.image = image;
        [self.view setBackgroundColor:[UIColor whiteColor]];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[UIColor blackColor]];

    //size and make webView
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    self.webView = [[UIWebView alloc] initWithFrame:frame];
    [self.webView setBackgroundColor:[UIColor blackColor]];
    [self.webView setDelegate:self];
    [self loadWebView];
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    if ([self isNetworkAvailable:@"mit.edu"]) {
        [self loadWebView];
    } else {
        [self loadBlackView];
    }
    // lhas to happen here, because the web view needs to be resized
    // If the user *just* created their datahub account, the webView script needs to be regenerated
    // because it will initially be null
    
}

- (void) loadBlackView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);

    UIView *blackView = [[UIView alloc] initWithFrame:frame];
    [blackView setBackgroundColor:[UIColor blackColor]];
    
    UILabel *noInternetLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, screenRect.size.width-40, 100)];
    [noInternetLabel setText:@"Graphs will load when an internet connection becomes available."];
    [noInternetLabel setNumberOfLines:0];
    [noInternetLabel setTextAlignment:NSTextAlignmentCenter];
    [noInternetLabel setTextColor:[UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0]];
    
    
    [blackView addSubview:noInternetLabel];
    [self.view addSubview:blackView];
}

- (void) loadWebView {
    
    
    
    // this is dumb, but we have to convert the html to a string and then display that, because of Safari's XSS issues.
    NSURL *url = [NSURL URLWithString:@"https://arcarter.scripts.mit.edu/getfit-html/datahubGraphs.html"];
    NSString *htmlString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlString baseURL:nil];

    
//    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"datahubGraphs" ofType:@"html"];
//    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
//    [self.webView loadHTMLString:htmlString baseURL:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    Secret *secret = [Secret sharedSecret];
    NSString *app_id = secret.DHAppID;
    NSString *app_token = secret.DHAppToken;
    NSString *repo_base = [defaults stringForKey:@"username"];
    
    // update HTMl using keys and generate chart
    self.script = [NSString stringWithFormat:@"var app_id = '%@'; var app_token = '%@'; var repo_base = '%@'; makeCharts();", app_id, app_token, repo_base];
    NSLog(@"%@", self.script);
    
    [self.webView stringByEvaluatingJavaScriptFromString:self.script];
    
    [self.view addSubview:self.webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.webView stringByEvaluatingJavaScriptFromString:self.script];
}

-(BOOL)isNetworkAvailable:(NSString *)hostname
{
    const char *cHostname = [hostname UTF8String];
    struct hostent *hostinfo;
    hostinfo = gethostbyname (cHostname);
    if (hostinfo == NULL){
        NSLog(@"-> no connection!\n");
        return NO;
    }
    else{
        NSLog(@"-> connection established!\n");
        return YES;
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
