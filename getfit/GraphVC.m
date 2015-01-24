//
//  GraphVC.m
//  GetFit
//
//  Created by Albert Carter on 12/17/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import "GraphVC.h"
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

    [self loadWebView];
    
}

- (void) viewWillAppear:(BOOL)animated {
    [self.webView stringByEvaluatingJavaScriptFromString:self.script];
}

- (void) loadWebView {
    
    //size and make webView
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    self.webView = [[UIWebView alloc] initWithFrame:frame];
    [self.webView setBackgroundColor:[UIColor blackColor]];
    [self.webView setDelegate:self];
    
    
    // this is dumb, but we have to convert the html to a string and then display that, because of Safari's XSS issues.
    NSURL *url = [NSURL URLWithString:@"https://arcarter.scripts.mit.edu/getfit-html/datahubGraphs.html"];
    NSString *htmlString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlString baseURL:nil];

    
//    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"datahubGraphs" ofType:@"html"];
//    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
//    [self.webView loadHTMLString:htmlString baseURL:nil];
    
    // load important keys
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    Secret *secret = [Secret sharedSecret];
    NSString *app_id = secret.DHAppID;
    NSString *app_token = secret.DHAppToken;
    NSString *repo_base = [defaults stringForKey:@"username"];
    
    // update HTMl using keys and generate chart
    self.script = [NSString stringWithFormat:@"var app_id = '%@'; var app_token = '%@'; var repo_base = '%@'; makeCharts();", app_id, app_token, repo_base];
    NSLog(@"%@", self.script);
    
    [self.view addSubview:self.webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [self.webView stringByEvaluatingJavaScriptFromString:self.script];
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
