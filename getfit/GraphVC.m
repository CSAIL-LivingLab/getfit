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


@end

@implementation GraphVC {
    CGSize bounds;

    
    UIView *blackView;
    UIActivityIndicatorView *workingSpinner;
    UILabel *loadingLabel;
    
    UIWebView *webView;
    NSString *script;
}

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
    bounds = [UIScreen mainScreen].bounds.size;
    
    // make the initial web view
    // we'll just be loading scripts later
    [self loadBlackView];
    [self loadWebView];
   }

- (void) viewWillAppear:(BOOL)animated {
    [self refreshWebViewData];
}

- (void) loadBlackView {
    CGRect frame = CGRectMake(0, 0, bounds.width, bounds.height);

    blackView = [[UIView alloc] initWithFrame:frame];
    [blackView setBackgroundColor:[UIColor blackColor]];

    // label
    UILabel *blackViewLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 150, bounds.width-8, 40)];
    [blackViewLabel setNumberOfLines:0];
    [blackViewLabel setTextAlignment:NSTextAlignmentCenter];
    [blackViewLabel setTextColor:[UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0]];

    if ([self isNetworkAvailable:@"mit.edu"]) {
        [blackViewLabel setText:@"Graphs are loading."];
    } else {
        [blackViewLabel setText:@"Graphs will load when an internet connection becomes available."];
    }
    [blackView addSubview:blackViewLabel];
    
    
    // working spinner
    workingSpinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(bounds.width/2-30, 180, 60, 60)];
    workingSpinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [workingSpinner startAnimating];
    [blackView addSubview:workingSpinner];

    
    [self setView:blackView];
}

- (void) loadWebView {
    
    webView = [[UIWebView alloc] initWithFrame:CGRectMake(0, 0, bounds.height, bounds.width)];
    [webView setBackgroundColor:[UIColor blackColor]];
    [webView setDelegate:self];

    
    // this is dumb, but we have to convert the html to a string and then display that, because of Safari's XSS issues.
    NSURL *url = [NSURL URLWithString:@"https://arcarter.scripts.mit.edu/getfit-html/datahubGraphs.html"];
    NSString *htmlString = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    [webView loadHTMLString:htmlString baseURL:nil];

    
//    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"datahubGraphs" ofType:@"html"];
//    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
//    [self.webView loadHTMLString:htmlString baseURL:nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    Secret *secret = [Secret sharedSecret];
    NSString *app_id = secret.DHAppID;
    NSString *app_token = secret.DHAppToken;
    NSString *repo_base = [defaults stringForKey:@"username"];
    
    // update HTMl using keys and generate chart
    script = [NSString stringWithFormat:@"var app_id = '%@'; var app_token = '%@'; var repo_base = '%@'; makeCharts();", app_id, app_token, repo_base];
}

- (void) refreshWebViewData {
    [webView stringByEvaluatingJavaScriptFromString:script];
}

- (void)webViewDidFinishLoad:(UIWebView *)localWebView {
    [self refreshWebViewData];
    [self fadeInNewView:webView];
}

# pragma mark - helpers

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

- (void) fadeInNewView:(UIView *) newView{
    // fade a new view in from an old one
    
    // take a picture of the old view
    CGRect rect = [self.view bounds];
    UIGraphicsBeginImageContextWithOptions(rect.size,YES,0.0f);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [self.view.layer renderInContext:context];
    UIImage *capturedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // add the picture the top of the new view
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:rect];
    [imageView setImage:capturedImage];
    [newView addSubview:imageView];
    
    // make the new view the root view
    [self setView:newView];
    
    // fade out the image
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        [imageView setAlpha:0];
        
    }completion:^(BOOL done){
        // remove it from superview to avoid memory leaks
        imageView.hidden = YES;
        [imageView removeFromSuperview];
    }];
}

@end
