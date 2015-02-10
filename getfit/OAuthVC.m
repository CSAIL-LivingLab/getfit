//
//  OAuthVC.m
//  GetFit
//
//  Created by Albert Carter on 12/5/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import "OAuthVC.h"
#import "MinuteStore.h"
#import "MinuteTVC.h"
#import "Resources.h"

@interface OAuthVC ()

@end

@implementation OAuthVC {
    UIWebView *myWebView;
    NSString *email;
    NSString *token;
    NSUserDefaults *defaults;
    BOOL success;
}

- (id) initWithDelegate:(UIViewController<OAuthVCDelegate> *)delegateVC {
    self = [super init];
    if (self) {
        _delegate = delegateVC;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.topItem.title = @"Please Log In to GetFit";
    // make a bar button
    [self makeCancelButton];
    
    // make the web view load
    [self setupWebView];
    
    // prep defaults
    defaults = [NSUserDefaults standardUserDefaults];
    
}

- (void) dismissWithoutNotification {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UI Setup

- (void) makeCancelButton {
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                    style:UIBarButtonItemStylePlain target:self action:@selector(dismissWithoutNotification)];
    self.navigationItem.leftBarButtonItem = leftButton;
}

- (void) setupWebView {
    // layout view
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    myWebView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width ,screenRect.size.height)];
    myWebView.delegate = self;
    
    // If the certs are good, go to GetFit. Otherwise, clear the user's cookies and
    // prompt them to log in.
    NSURL *nsurl;
    MinuteStore *ms = [MinuteStore sharedStore];
    if ([ms checkForValidCookies]) {
        nsurl = [NSURL URLWithString: @"https://getfit.mit.edu/dashboard"];
    } else {
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (NSHTTPCookie *cookie in [storage cookies]) {
            [storage deleteCookie:cookie];
        }
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        nsurl=[NSURL URLWithString:@"https://getfit.mit.edu/Shibboleth.sso/WAYF?target=https%3A%2F%2Fgetfit.mit.edu%2F%3Fq%3Dshib_login%2Fdashboard"];
    }
    
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [myWebView loadRequest:nsrequest];
    [self.view addSubview:myWebView];

}

# pragma mark - helper methods

- (void) extractTokensAndSave {
    
    NSURL *jsUrl = [NSURL URLWithString:@"https://arcarter.scripts.mit.edu/getfit-html/tokenExtraction-090.js"];
    NSString *javascriptToRun = [NSString stringWithContentsOfURL:jsUrl encoding:NSUTF8StringEncoding error:nil];
    
    [myWebView stringByEvaluatingJavaScriptFromString:javascriptToRun];
    
    // parse tokens
    NSArray *form_tokens = [[myWebView stringByEvaluatingJavaScriptFromString:@"csail.getFilteredTokens().toString();"] componentsSeparatedByString:@","];
    NSArray *form_build_ids = [[myWebView stringByEvaluatingJavaScriptFromString:@"csail.getFilteredBuildIds().toString();"]componentsSeparatedByString:@","];
    NSArray *form_ids = [[myWebView stringByEvaluatingJavaScriptFromString:@"csail.getFilteredFormIds().toString();"] componentsSeparatedByString:@","];
    
    NSLog(@"%@", form_tokens);
    NSLog(@"%@", form_ids);
    NSLog(@"%@", form_build_ids);
    
    // set save as defaults.
    [defaults setObject:form_tokens forKey:@"form_tokens"];
    [defaults setObject:form_build_ids forKey:@"form_build_ids"];
    [defaults setObject:form_ids forKey:@"form_ids"];
    [defaults setObject:[NSDate date] forKey:@"last_token_extract"];
    [defaults synchronize];
    
    // once tokens are extracted, post to getFit and close the page
    MinuteStore *ms = [MinuteStore sharedStore];
    
    success = [ms postToGetFit];
    [_delegate didDismissOAuthVCWithSuccessfulExtraction:success];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) hideWebViewAndShowSpinnerView {
    myWebView.hidden = YES;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // white view
    UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    [backgroundView setBackgroundColor:[UIColor blackColor]];
    
    // activity indicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(screenRect.size.width/2-30, screenRect.size.height/2-30, 60, 60)];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [activityIndicator startAnimating];
    
    
    // label
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(screenRect.size.width/2-150, screenRect.size.height/2+20, 300, 40)];
    message.text = @"Sending Data to GetFit";
    message.font = [UIFont systemFontOfSize:20];
    message.textColor = [UIColor grayColor];
    message.textAlignment = NSTextAlignmentCenter;
    
    
    // add the views
    [backgroundView addSubview:activityIndicator];
    [backgroundView addSubview:message];
    [self fadeInNewView:backgroundView];
}



#pragma mark - UIWebViewDelegate

- (void) webViewDidStartLoad:(UIWebView *)webView {
    NSString *url = [webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
    NSLog(@"\n\nURL: %@", url);
    
    // detect the redirect url (https://idp.mit.edu/idp/profile/SAML2/Redirect/SSO)
    // because the dashboard url will only show in webViewDidFinishLoad
    if ([url rangeOfString:@"Authn/MIT"].location != NSNotFound) {
        [self hideWebViewAndShowSpinnerView];
    }
    
}

- (void) webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *url = [webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
    
    // do nothing unless it's a getfit url. have to check because dashboard might sometimes pass this.
    if ([url rangeOfString:@"getfit"].location == NSNotFound || [url rangeOfString:@"idp.mit.edu"].location != NSNotFound) {
        return;
    }
    
    // extrac the tokens.
    if ([url rangeOfString:@"dashboard"].location != NSNotFound) {
        [self extractTokensAndSave];
    }

    
}

- (void) webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (!self.isViewLoaded || !self.view.window) {
        return;
    }
    
    // dismiss the view and tell the delegate to show the alert
    [_delegate didDismissOAuthVCWithSuccessfulExtraction:NO];
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    // add this view to the top of the other
    // this is different from most fadeInNewView methods, since the root view is preserved
    [self.view addSubview:newView];
    
    // fade out the image
    [UIView animateWithDuration:0.5 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        [imageView setAlpha:0];
        
    }completion:^(BOOL done){
        // remove it from superview to avoid memory leaks
        imageView.hidden = YES;
        [imageView removeFromSuperview];
    }];
}

@end
