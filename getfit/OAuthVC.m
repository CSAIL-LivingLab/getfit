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


- (void)dismiss {
    // check to make sure the view is actually visible. The interval timer might cause alerts to be called, otherwise
    if (!self.isViewLoaded || !self.view.window) {
        return;
    }
        
    // dismiss the view after the user clicks ok.
    // Uses UIAlertViewDelegate didDismissWithButtonIndex
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Minutes Saved" message:@"" delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alertView show];
}

- (void) dismissWithoutSaving {
    if (!self.isViewLoaded || !self.view.window) {
        return;
    }
    
    if (self.minuteTVC !=nil) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        [self.minuteTVC dismissViewControllerAnimated:YES completion:nil];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}



#pragma mark - UI Setup

- (void) alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
        if (self.minuteTVC !=nil) {
            [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
            [self.minuteTVC dismissViewControllerAnimated:YES completion:nil];
        }
    
        [self dismissViewControllerAnimated:YES completion:nil];
}

- (void) makeCancelButton {
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                    style:UIBarButtonItemStylePlain target:self action:@selector(dismissWithoutSaving)];
    self.navigationItem.leftBarButtonItem = leftButton;
}

- (void) setupWebView {
    // layout view
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    myWebView=[[UIWebView alloc]initWithFrame:CGRectMake(0, 0, screenRect.size.width ,screenRect.size.height)];
    myWebView.delegate = self;
    
    // If the certs are good, go to GetFit. Otherwise, assume that the user will need to log in.
    NSURL *nsurl;
    MinuteStore *ms = [MinuteStore sharedStore];
    if ([ms checkForValidCookies]) {
        nsurl = [NSURL URLWithString: @"https://getfit-d7-dev.mit.edu/dashboard"];
    } else {
        nsurl=[NSURL URLWithString:@"https://getfit-d7-dev.mit.edu/Shibboleth.sso/Login?target=https%3A%2F%2Fgetfit-d7-dev.mit.edu%2F%3Fq%3Dshib_login%2Ffront-page"];
    }
    
    NSURLRequest *nsrequest=[NSURLRequest requestWithURL:nsurl];
    [myWebView loadRequest:nsrequest];
    [self.view addSubview:myWebView];

}

# pragma mark - helper methods

- (void) extractTokensAndSave {
    [myWebView stringByEvaluatingJavaScriptFromString:@"function getTokens () {    var form_token_objects = document.getElementsByName('form_token');    var form_tokens = [];        for (var i =  0; i < form_token_objects.length; i++) {        var value = form_token_objects[i].value;        form_tokens.push(value);    };    return form_tokens;}function getBuildIds() {    var form_build_id_objects = document.getElementsByName('form_build_id');    var form_build_ids = [];    for (var i =  0; i < form_build_id_objects.length; i++) {        var value = form_build_id_objects[i].value;        form_build_ids.push(value);    };    return form_build_ids;}    function getFormIds() {    var form_id_objects = document.getElementsByName('form_id');    var form_ids = [];        for (var i =  0; i < form_id_objects.length; i++) {    var value = form_id_objects[i].value;    form_ids.push(value);    };    return form_ids;}function getStartIndex() {    var ids = getFormIds();    for (var i = 0; i < ids.length; i++) {        var id = ids[i];        if (id == 'getfit_minutes_single_form_1') {            return i;        };    };}"];
    
    // parse tokens
    NSArray *form_tokens = [[myWebView stringByEvaluatingJavaScriptFromString:@"getTokens().toString();"] componentsSeparatedByString:@","];
    NSArray *form_build_ids = [[myWebView stringByEvaluatingJavaScriptFromString:@"getBuildIds().toString();"]componentsSeparatedByString:@","];
    NSArray *form_ids = [[myWebView stringByEvaluatingJavaScriptFromString:@"getFormIds().toString();"] componentsSeparatedByString:@","];
    
    NSString *indexStr = [myWebView stringByEvaluatingJavaScriptFromString:@"getStartIndex().toString();"];
    NSInteger indexInt = [indexStr integerValue];
    
    
    // strip the arrays up to the index
    // save the array
    form_tokens = [form_tokens subarrayWithRange:NSMakeRange(indexInt, [form_tokens count]-2)];
    form_ids = [form_ids subarrayWithRange:NSMakeRange(indexInt, [form_ids count]-2)];
    form_build_ids = [form_build_ids subarrayWithRange:NSMakeRange(indexInt, [form_build_ids count]-2)];
    
//    NSLog(@"%@", form_tokens);
//    NSLog(@"%@", form_ids);
//    NSLog(@"%@", form_build_ids);

    
    
    // set save as defaults.
    [defaults setObject:form_tokens forKey:@"form_tokens"];
    [defaults setObject:form_build_ids forKey:@"form_build_ids"];
    [defaults setObject:form_ids forKey:@"form_ids"];
    [defaults setObject:[NSDate date] forKey:@"last_token_extract"];
    [defaults synchronize];
    
    // once tokens are extracted, post to getFit and close the page
    MinuteStore *ms = [MinuteStore sharedStore];
    
    [ms postToGetFit];
    [self dismiss];
}

- (void) hideWebViewAndShowSpinnerView {
    myWebView.hidden = YES;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    
    // white view
    UIView *whiteView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, screenRect.size.height)];
    
    // activity indicator
    UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(screenRect.size.width/2-30, screenRect.size.height/2-30, 60, 60)];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    [activityIndicator startAnimating];
    
    
    // label
    UILabel *message = [[UILabel alloc] initWithFrame:CGRectMake(screenRect.size.width/2-150, screenRect.size.height/2+20, 300, 40)];
    message.text = @"Sending Data to GetFit";
    message.font = [UIFont systemFontOfSize:20];
    message.textColor = [UIColor grayColor];
    message.textAlignment = NSTextAlignmentCenter;
    
    
    // add the views
    [whiteView addSubview:activityIndicator];
    [whiteView addSubview:message];
    [self.view addSubview:whiteView];
    
    // make sure the view eventually dissapears, even if the web view doesn't load
    NSTimeInterval delay = 15;
    [self performSelector:@selector(dismiss) withObject:nil afterDelay:delay];
}



#pragma mark - UIWebViewDelegate

- (void) webViewDidStartLoad:(UIWebView *)webView {
    NSString *url = [webView stringByEvaluatingJavaScriptFromString:@"document.URL"];
//    NSLog(@"\n\nURL: %@", url);
    
    // detect the redirect url (https://idp.mit.edu/idp/profile/SAML2/Redirect/SSO)
    // because the dashboard url will only show in webViewDidFinishLoad
    if ([url rangeOfString:@"SAML2/Redirect"].location != NSNotFound) {
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
    
    // dismiss the view after the user clicks ok.
    // Uses UIAlertViewDelegate didDismissWithButtonIndex
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"There was a problem loading getfit. Your minutes are saved on your phone and there is no need to re-enter them. The app will post to GetFit later." delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil];
    [alertView show];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
