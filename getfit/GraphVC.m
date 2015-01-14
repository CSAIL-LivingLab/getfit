//
//  GraphVC.m
//  GetFit
//
//  Created by Albert Carter on 12/17/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import "GraphVC.h"

@interface GraphVC ()

@property UIWebView *webView;

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

- (void) loadWebView {
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    CGRect frame = CGRectMake(0, 0, screenRect.size.width, screenRect.size.height);
    
    self.webView = [[UIWebView alloc] initWithFrame:frame];
    
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"datahubGraphs" ofType:@"html"];
    NSString* htmlString = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:htmlString baseURL:nil];
    [self.view addSubview:self.webView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
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
