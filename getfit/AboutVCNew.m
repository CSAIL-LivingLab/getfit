//
//  AboutVCNew.m
//  GetFit
//
//  Created by Albert Carter on 2/13/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import "AboutVCNew.h"

@interface AboutVCNew ()

@end

@implementation AboutVCNew {
    UIScrollView *scrollView;
    UIView *contentView;
    
    UIColor *blueColor;
    UIColor *greenColor;
    UIImage *pauseImage;
    NSUserDefaults *defaults;
    
    UIPickerView *pausePicker;
    NSArray *pauseArr;
    UILabel *pauseText;
    
    UILabel *appTitle;
    UITextView *appTextView;
    
    UILabel *datahubTitle;
    UITextView *datahubTextView;
    
    UILabel *yourDataTitle;
    UITextView *yourDataTextView;
    
    // these are all text views for selecting and alignment purposes
    UITextView *username;
    UITextView *storedUsername;
    UITextView *password;
    UITextView *storedPassword;
    
    UILabel *sensingTitle;
    UITextView *sensingTextView;
    
    
    UIButton *pauseButton;
    UITextView *sensingIncludesTextView;
    
    UILabel *livingLabTitle;
    UITextView *livingLabTextView;
    
    UILabel *faqTitle;
    UITextView *faqTextView;
    
    
}

#define kFONT_NAME_BOLD @"HelveticaNeue-Bold"
#define kFONT_NAME @"HelveticaNeue-Light"

#define kPAUSE_TITLE @"pause\nsensors"
#define kRESUME_TITLE @"resume\nsensors"


- (instancetype) init {
    self = [super init];
    if (self) {
        // some variables to be used throughout
        defaults = [NSUserDefaults standardUserDefaults];
        blueColor = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
        greenColor = [UIColor colorWithRed:.1 green:.8 blue:.1 alpha:1.0];
        CGSize bounds = CGSizeMake([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
        
        // setup main view
        UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.width, bounds.height)];
        self.view = mainView;
        [self.view setBackgroundColor:[UIColor blackColor]];
        
        // setup scroll view and add to main view
        scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, bounds.width, bounds.height)];
        [scrollView setScrollEnabled:YES];
        [scrollView setContentSize:CGSizeMake(bounds.width, 900)];
        [self.view addSubview:scrollView];
        
        // setup content view and add to scroll view
        contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.width, 800)];
        [scrollView addSubview:contentView];
        
        
        // define relative variables
        CGFloat offsetFromTop = 15;
        
        // setup app info
        appTitle = [[UILabel alloc] initWithFrame:CGRectMake(8, offsetFromTop, bounds.width-16, 15)];
        [appTitle setText:@"About The GetFit App"];
        [appTitle setTextColor:greenColor];
        [appTitle setBackgroundColor:[UIColor clearColor]];
        [appTitle setFont:[UIFont systemFontOfSize:17]];
        [appTitle setTextAlignment:NSTextAlignmentCenter];
        [contentView addSubview:appTitle];
        
        appTextView = [[UITextView alloc] initWithFrame:CGRectMake(8, offsetFromTop + appTitle.bounds.size.height, bounds.width-16, 40)];
        appTextView.editable = NO;
        NSString *appTextViewString = @"<style>* {    font-family: \"Helvetica Neue\"; text-align:justify;</style>This app, created by the <a href=\"http://livinglab.mit.edu/\">MIT bigdata Living Lab</a>, allows users to record and log activity data for the <a href=\"https://getfit.mit.edu/\">getfit@mit</a> challenge. The app also allows users to record and submit this activity data to a Personal Data Store on CSAIL’s DataHub.";
        NSData *appTextViewData = [appTextViewString dataUsingEncoding:NSUnicodeStringEncoding];
        NSAttributedString *appTextViewAttributedString= [[NSAttributedString alloc] initWithData:appTextViewData options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        [appTextView setAttributedText:appTextViewAttributedString];
        [appTextView setTextColor:[UIColor whiteColor]];
        [appTextView setBackgroundColor:[UIColor clearColor]];
        [appTextView setTintColor:greenColor];
        [appTextView setDataDetectorTypes:UIDataDetectorTypeAll];
        [appTextView setFont:[UIFont systemFontOfSize:12]];
        [appTextView setTextAlignment:NSTextAlignmentJustified];
        [appTextView sizeToFit];
        [contentView addSubview:appTextView];
        
        CGFloat appInfoOffset = appTextView.frame.origin.y + appTextView.frame.size.height;
        
        // setup datahub info
        datahubTitle = [[UILabel alloc] initWithFrame:CGRectMake(8, 4+appInfoOffset, bounds.width-16, 15)];
        [datahubTitle setText:@"About DataHub"];
        [datahubTitle setTextColor:greenColor];
        [datahubTitle setBackgroundColor:[UIColor clearColor]];
        [datahubTitle setFont:[UIFont systemFontOfSize:17]];
        [datahubTitle setTextAlignment:NSTextAlignmentCenter];
        [contentView addSubview:datahubTitle];
        
        datahubTextView =[[UITextView alloc] initWithFrame:CGRectMake(8, appInfoOffset + datahubTitle.bounds.size.height, bounds.width-16, 40)];
        datahubTextView.editable = NO;
        NSString *dataHubTextViewString = @"<style>* {    font-family: \"Helvetica Neue\"; text-align:justify;</style><a href=\"https://datahub.csail.mit.edu\">DataHub</a> is a unified data management and collaboration platform under development at MIT CSAIL.";
        NSData *datahubTextViewData = [dataHubTextViewString dataUsingEncoding:NSUnicodeStringEncoding];
        NSAttributedString *datahubTextViewAttributedString= [[NSAttributedString alloc] initWithData:datahubTextViewData options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        [datahubTextView setAttributedText:datahubTextViewAttributedString];
        [datahubTextView setTextColor:[UIColor whiteColor]];
        [datahubTextView setBackgroundColor:[UIColor clearColor]];
        [datahubTextView setTintColor:greenColor];
        [datahubTextView setDataDetectorTypes:UIDataDetectorTypeAll];
        [datahubTextView setFont:[UIFont systemFontOfSize:12]];
        [datahubTextView setTextAlignment:NSTextAlignmentJustified];
        [datahubTextView sizeToFit];
        [contentView addSubview:datahubTextView];
        
        CGFloat datahubInfoOffset = datahubTextView.frame.origin.y + datahubTextView.frame.size.height;
        
        // setup your data section
        yourDataTitle = [[UILabel alloc] initWithFrame:CGRectMake(8, 4+datahubInfoOffset, bounds.width-16, 15)];
        [yourDataTitle setText:@"Your Data"];
        [yourDataTitle setTextColor:greenColor];
        [yourDataTitle setBackgroundColor:[UIColor clearColor]];
        [yourDataTitle setFont:[UIFont systemFontOfSize:17]];
        [yourDataTitle setTextAlignment:NSTextAlignmentCenter];
        [contentView addSubview:yourDataTitle];
        
        yourDataTextView = [[UITextView alloc] initWithFrame:CGRectMake(8, datahubInfoOffset + yourDataTitle.frame.size.height, bounds.width-16, 40)];
        yourDataTextView.editable = NO;
        NSString *yourDataTextViewString = @"<style>* {    font-family: \"Helvetica Neue\"; text-align:justify;</style>This app will create a data store for you on DataHub. You can access your personal data on DataHub <a href=\"https://datahub.csail.mit.edu/\">https://datahub.csail.mit.edu</a> using the following:";
        NSData *yourDataTextViewData = [yourDataTextViewString dataUsingEncoding:NSUnicodeStringEncoding];
        NSAttributedString *yourDataTextViewAttributedString= [[NSAttributedString alloc] initWithData:yourDataTextViewData options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        [yourDataTextView setAttributedText:yourDataTextViewAttributedString];
        [yourDataTextView setTextColor:[UIColor whiteColor]];
        [yourDataTextView setBackgroundColor:[UIColor clearColor]];
        [yourDataTextView setTintColor:greenColor];
        [yourDataTextView setDataDetectorTypes:UIDataDetectorTypeAll];
        [yourDataTextView setFont:[UIFont systemFontOfSize:12]];
        [yourDataTextView setTextAlignment:NSTextAlignmentJustified];
        [yourDataTextView sizeToFit];
        [contentView addSubview:yourDataTextView];
        
        // username and password
        username = [[UITextView alloc] initWithFrame:CGRectMake(8, yourDataTextView.frame.size.height + yourDataTextView.frame.origin.y, bounds.width/2-12, 22)];
        username.scrollEnabled = NO;
        username.editable = NO;
        [username setText:@"username:"];
        [username setTextColor:[UIColor whiteColor]];
        [username setBackgroundColor:[UIColor clearColor]];
        [username setFont:[UIFont systemFontOfSize:13]];
        [username setTextAlignment:NSTextAlignmentRight];
        [contentView addSubview:username];
        
        password = [[UITextView alloc] initWithFrame:CGRectMake(8, username.frame.size.height + username.frame.origin.y, bounds.width/2-12, 22)];
        password.scrollEnabled = NO;
        password.editable = NO;
        [password setText:@"password:"];
        [password setTextColor:[UIColor whiteColor]];
        [password setBackgroundColor:[UIColor clearColor]];
        [password setFont:[UIFont systemFontOfSize:13]];
        [password setTextAlignment:NSTextAlignmentRight];
        [contentView addSubview:password];
        
        storedUsername = [[UITextView alloc] initWithFrame:CGRectMake(bounds.width/2+4, yourDataTextView.frame.size.height + yourDataTextView.frame.origin.y, bounds.width/2-4, 22)];
        storedUsername.scrollEnabled = NO;
        storedUsername.editable = NO;
        [storedUsername setText:[defaults objectForKey:@"username"]];
        [storedUsername setTextColor:[UIColor whiteColor]];
        [storedUsername setBackgroundColor:[UIColor clearColor]];
        [storedUsername setFont:[UIFont systemFontOfSize:13]];
        [storedUsername setTextAlignment:NSTextAlignmentLeft];
        [contentView addSubview:storedUsername];
        
        storedPassword = [[UITextView alloc] initWithFrame:CGRectMake(bounds.width/2+4, storedUsername.frame.size.height + storedUsername.frame.origin.y, bounds.width/2-4, 22)];
        storedPassword.scrollEnabled = NO;
        storedPassword.editable = NO;
        [storedPassword setText:[defaults objectForKey:@"password"]];
        [storedPassword setTextColor:[UIColor whiteColor]];
        [storedPassword setBackgroundColor:[UIColor clearColor]];
        [storedPassword setFont:[UIFont systemFontOfSize:13]];
        [storedPassword setTextAlignment:NSTextAlignmentLeft];
        [contentView addSubview:storedPassword];

        
        // setup sensing info
        sensingTitle = [[UILabel alloc] initWithFrame:CGRectMake(8, storedPassword.frame.origin.y + storedPassword.frame.size.height + 8, bounds.width-16, 15)];
        [sensingTitle setText:@"Continuous Data Logging Mode"];
        [sensingTitle setTextColor:greenColor];
        [sensingTitle setBackgroundColor:[UIColor clearColor]];
        [sensingTitle setFont:[UIFont systemFontOfSize:17]];
        [sensingTitle setTextAlignment:NSTextAlignmentCenter];
        [contentView addSubview:sensingTitle];
        

        sensingTextView =[[UITextView alloc] initWithFrame:CGRectMake(8,sensingTitle.frame.size.height + sensingTitle.frame.origin.y, bounds.width-16, 40)];
        sensingTextView.editable = NO;
        sensingTextView.scrollEnabled = NO;
        [sensingTextView setText:@"Continuous Data Logging Mode allows users to gather mobile sensor data and upload it to a Personal Data Store on DataHub. You may turn on or off this function at any time."];
        [sensingTextView setTextColor:[UIColor whiteColor]];
        [sensingTextView setBackgroundColor:[UIColor clearColor]];
        [sensingTextView setTintColor:greenColor];
        [sensingTextView setDataDetectorTypes:UIDataDetectorTypeAll];
        [sensingTextView setFont:[UIFont systemFontOfSize:12]];
        [sensingTextView setTextAlignment:NSTextAlignmentJustified];
        [sensingTextView sizeToFit];
        [contentView addSubview:sensingTextView];
        
        // setup pause button
        pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(bounds.width/2-55, sensingTextView.frame.origin.y + sensingTextView.frame.size.height + 5, 110, 110)];
        pauseButton.backgroundColor = blueColor;
        pauseButton.layer.cornerRadius = pauseButton.bounds.size.width/2;
        pauseButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
        pauseButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        pauseButton.layer.borderWidth = 2.0;
        [pauseButton setTitle:kPAUSE_TITLE forState:UIControlStateNormal];
        [pauseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [[pauseButton titleLabel] setFont:[UIFont fontWithName:kFONT_NAME size:15]];
        [pauseButton.layer setBackgroundColor:[blueColor CGColor]];
        [pauseButton addTarget:self action:@selector(addPicker:) forControlEvents:UIControlEventTouchUpInside];
        pauseButton.titleLabel.numberOfLines = 2;
        pauseButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [contentView addSubview:pauseButton];
        
        
        // sensing includes text
        NSString *sensingIncludesTextViewString = @"<style>* {    font-family: \"Helvetica Neue\"; text-align:justify;</style>Mobile sensor data includes: motion sensors (gyroscope, accelerometer), activity info, position data and basic device info.  It does <span style=\"font-style: italic;\">not</span> include content or call logs from phone or txt messages (SMS), <span style=\"font-style: italic;\">>nor</span> do we capture any audio or video with this app.";
        NSData *sensingIncludesData = [sensingIncludesTextViewString dataUsingEncoding:NSUnicodeStringEncoding];
        NSAttributedString *sensingIncludesAttributedString= [[NSAttributedString alloc] initWithData:sensingIncludesData options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        sensingIncludesTextView =[[UITextView alloc] initWithFrame:CGRectMake(8,pauseButton.frame.size.height + pauseButton.frame.origin.y, bounds.width-16, 40)];
        sensingIncludesTextView.editable = NO;
        [sensingIncludesTextView setAttributedText:sensingIncludesAttributedString];
        [sensingIncludesTextView setTextColor:[UIColor whiteColor]];
        [sensingIncludesTextView setBackgroundColor:[UIColor clearColor]];
        [sensingIncludesTextView setTintColor:greenColor];
        [sensingIncludesTextView setDataDetectorTypes:UIDataDetectorTypeAll];
        [sensingIncludesTextView setFont:[UIFont systemFontOfSize:12]];
        [sensingIncludesTextView setTextAlignment:NSTextAlignmentJustified];
        [sensingIncludesTextView sizeToFit];
        [contentView addSubview:sensingIncludesTextView];
        
        
        // livinglab
        livingLabTitle = [[UILabel alloc] initWithFrame:CGRectMake(8, sensingIncludesTextView.frame.origin.y + sensingIncludesTextView.frame.size.height + 8, bounds.width-16, 15)];
        [livingLabTitle setText:@"About MIT Living Lab"];
        [livingLabTitle setTextColor:greenColor];
        [livingLabTitle setBackgroundColor:[UIColor clearColor]];
        [livingLabTitle setFont:[UIFont systemFontOfSize:17]];
        [livingLabTitle setTextAlignment:NSTextAlignmentCenter];
        [contentView addSubview:livingLabTitle];
        
        NSString *livingLabTextViewString = @"<style>* {    font-family: \"Helvetica Neue\"; text-align:justify;</style>The <a href=\"https://livinglab.mit.edu/\">MIT bigdata Living Lab</a> is building scalable data management tools and applications that enable researchers at MIT to demo new approaches to collecting, combining and using data for good on campus.";
        NSData *livingLabData = [livingLabTextViewString dataUsingEncoding:NSUnicodeStringEncoding];
        NSAttributedString *livingLabAttributedString= [[NSAttributedString alloc] initWithData:livingLabData options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        livingLabTextView =[[UITextView alloc] initWithFrame:CGRectMake(8,livingLabTitle.frame.size.height + livingLabTitle.frame.origin.y, bounds.width-16, 40)];
        livingLabTextView.editable = NO;
        [livingLabTextView setAttributedText:livingLabAttributedString];
        [livingLabTextView setTextColor:[UIColor whiteColor]];
        [livingLabTextView setBackgroundColor:[UIColor clearColor]];
        [livingLabTextView setTintColor:greenColor];
        [livingLabTextView setDataDetectorTypes:UIDataDetectorTypeAll];
        [livingLabTextView setFont:[UIFont systemFontOfSize:12]];
        [livingLabTextView setTextAlignment:NSTextAlignmentJustified];
        [livingLabTextView sizeToFit];
        [contentView addSubview:livingLabTextView];

        // faq
        faqTitle = [[UILabel alloc] initWithFrame:CGRectMake(8, livingLabTextView.frame.origin.y + livingLabTextView.frame.size.height + 8, bounds.width-16, 15)];
        [faqTitle setText:@"FAQ & Support"];
        [faqTitle setTextColor:greenColor];
        [faqTitle setBackgroundColor:[UIColor clearColor]];
        [faqTitle setFont:[UIFont systemFontOfSize:17]];
        [faqTitle setTextAlignment:NSTextAlignmentCenter];
        [contentView addSubview:faqTitle];
        
        NSString *faqTextViewString = @"<style>* {    font-family: \"Helvetica Neue\"; text-align:center;</style>Support: <a href=\"mailto:getfit-livinglab@csail.mit.edu\">getfit-livinglab@csail.mit.edu</a><br />FAQ: <a href=\"https://livinglab.mit.edu/getfit-faq\">livinglab.mit.edu/getfit-faq</a>";
        NSData *faqData = [faqTextViewString dataUsingEncoding:NSUnicodeStringEncoding];
        NSAttributedString *faqAttributedString= [[NSAttributedString alloc] initWithData:faqData options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        faqTextView =[[UITextView alloc] initWithFrame:CGRectMake(8,faqTitle.frame.size.height + faqTitle.frame.origin.y, bounds.width-16, 40)];
        faqTextView.editable = NO;
        [faqTextView setAttributedText:faqAttributedString];
        [faqTextView setTextColor:[UIColor whiteColor]];
        [faqTextView setBackgroundColor:[UIColor clearColor]];
        [faqTextView setTintColor:greenColor];
        [faqTextView setDataDetectorTypes:UIDataDetectorTypeAll];
        [faqTextView setFont:[UIFont systemFontOfSize:12]];
        [faqTextView setTextAlignment:NSTextAlignmentCenter];
//        [faqTextView sizeToFit];
        [contentView addSubview:faqTextView];

        
        
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
