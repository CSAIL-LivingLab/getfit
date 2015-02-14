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
    
    // picker view stuff
    UIView *pickerParentView;
    UIPickerView *pausePicker;
    UIButton *pausePickerDoneButton;
    NSArray *pauseArr;
    UILabel *pauseText;

    // block text
    UILabel *appTitle;
    UITextView *appTextView;
    
    UISwitch *appSwitch;
    UILabel *appSwitchLabel;
    
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
    UILabel *resumeLabel;
    
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
        // set the icon
        self.tabBarItem.title = @"About";
        UIImage *image = [UIImage imageNamed:@"info.png"];
        self.tabBarItem.image = image;

        
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
        [scrollView setContentSize:CGSizeMake(bounds.width, 950)];
        [self.view addSubview:scrollView];
        
        // setup content view and add to scroll view
        contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, bounds.width, 900)];
        [scrollView addSubview:contentView];
        
        // define relative variables
        CGFloat offsetFromTop = 15;
        
        // setup picker
        pausePicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width+2, 250)];
        pausePicker.dataSource = self;
        pausePicker.delegate = self;
        [pausePicker setBackgroundColor:[UIColor blackColor]];
        pausePicker.layer.borderColor = [UIColor lightGrayColor].CGColor;
        pausePicker.layer.borderWidth = 1;
        [pausePicker reloadAllComponents];
        
        pausePickerDoneButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50, 0, 50, 44)];
        [pausePickerDoneButton setTitle:@"Done" forState:UIControlStateNormal];
        [pausePickerDoneButton.titleLabel setTextAlignment:NSTextAlignmentRight];
        [pausePickerDoneButton.titleLabel setTextColor:[UIColor whiteColor]];
        [pausePickerDoneButton addTarget:self action:@selector(dismissPicker:) forControlEvents:UIControlEventTouchUpInside];
        [pausePickerDoneButton setUserInteractionEnabled:YES];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPicker:)];
        [pausePickerDoneButton addGestureRecognizer:tap];
        
        // make activity picker parent view, and add subviews
        pickerParentView = [[UIView alloc] initWithFrame:CGRectMake(-1, self.view.bounds.size.height-250, self.view.bounds.size.width+2, 216)];
        [pickerParentView addSubview:pausePicker];
        [pickerParentView addSubview:pausePickerDoneButton];
        UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPicker:)];
        [tapBackground setNumberOfTapsRequired:1];
        [self.view addGestureRecognizer:tapBackground];
        
        pauseArr = [[NSArray alloc] initWithObjects:@[@"Resume Data Donation", @0],
                    @[@"10 min", @10],
                    @[@"30 min", @30],
                    @[@"1 hr", @60],
                    @[@"2 hr", @120],
                    @[@"5 hr", @300],
                    @[@"10 hr", @600],
                    @[@"1 day", @1440],
                    @[@"1 week", @10080],
                    @[@"Forever", @999],
                    nil];
        
        
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
        
        // app switch label
        appSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(8, appTextView.frame.origin.y + appTextView.frame.size.height, 40, 25)];
        appSwitch.userInteractionEnabled = YES;
        [appSwitch addTarget:self action:@selector(appSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        [contentView addSubview:appSwitch];
        
        appSwitchLabel = [[UILabel alloc] initWithFrame:CGRectMake(appSwitch.frame.origin.x + appSwitch.frame.size.width + 4, appTextView.frame.origin.y + appTextView.frame.size.height+3, bounds.width - 50, 25)];
        [appSwitchLabel setText:@"Post to GetFit Website (requires MIT ID)"];
        [appSwitchLabel setTextColor:[UIColor whiteColor]];
        [appSwitchLabel setBackgroundColor:[UIColor clearColor]];
        [appSwitchLabel setFont:[UIFont systemFontOfSize:14]];
        [appSwitchLabel setTextAlignment:NSTextAlignmentLeft];
        [contentView addSubview:appSwitchLabel];
        
        // setup datahub info
        datahubTitle = [[UILabel alloc] initWithFrame:CGRectMake(8, 4+appSwitch.frame.origin.y + appSwitch.frame.size.height, bounds.width-16, 15)];
        [datahubTitle setText:@"About DataHub"];
        [datahubTitle setTextColor:greenColor];
        [datahubTitle setBackgroundColor:[UIColor clearColor]];
        [datahubTitle setFont:[UIFont systemFontOfSize:17]];
        [datahubTitle setTextAlignment:NSTextAlignmentCenter];
        [contentView addSubview:datahubTitle];
        
        datahubTextView =[[UITextView alloc] initWithFrame:CGRectMake(8, datahubTitle.frame.origin.y + datahubTitle.bounds.size.height, bounds.width-16, 40)];
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
        yourDataTextView.scrollEnabled = NO;
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
        username = [[UITextView alloc] initWithFrame:CGRectMake(8, yourDataTextView.frame.size.height + yourDataTextView.frame.origin.y - 10, bounds.width/2-12, 24)];
        username.scrollEnabled = NO;
        username.editable = NO;
        [username setText:@"username:"];
        [username setTextColor:[UIColor whiteColor]];
        [username setBackgroundColor:[UIColor clearColor]];
        [username setFont:[UIFont systemFontOfSize:13]];
        [username setTextAlignment:NSTextAlignmentRight];
        [contentView addSubview:username];
        
        password = [[UITextView alloc] initWithFrame:CGRectMake(8, username.frame.size.height + username.frame.origin.y- 5, bounds.width/2-12, 24)];
        password.scrollEnabled = NO;
        password.editable = NO;
        [password setText:@"password:"];
        [password setTextColor:[UIColor whiteColor]];
        [password setBackgroundColor:[UIColor clearColor]];
        [password setFont:[UIFont systemFontOfSize:13]];
        [password setTextAlignment:NSTextAlignmentRight];
        [contentView addSubview:password];
        
        storedUsername = [[UITextView alloc] initWithFrame:CGRectMake(bounds.width/2+4, yourDataTextView.frame.size.height + yourDataTextView.frame.origin.y- 10, bounds.width/2-4, 24)];
        storedUsername.scrollEnabled = NO;
        storedUsername.editable = NO;
        [storedUsername setText:[defaults objectForKey:@"username"]];
        [storedUsername setTextColor:[UIColor whiteColor]];
        [storedUsername setBackgroundColor:[UIColor clearColor]];
        [storedUsername setFont:[UIFont systemFontOfSize:13]];
        [storedUsername setTextAlignment:NSTextAlignmentLeft];
        [contentView addSubview:storedUsername];
        
        storedPassword = [[UITextView alloc] initWithFrame:CGRectMake(bounds.width/2+4, storedUsername.frame.size.height + storedUsername.frame.origin.y - 5, bounds.width/2-4, 24)];
        storedPassword.scrollEnabled = NO;
        storedPassword.editable = NO;
        [storedPassword setText:[defaults objectForKey:@"password"]];
        [storedPassword setTextColor:[UIColor whiteColor]];
        [storedPassword setBackgroundColor:[UIColor clearColor]];
        [storedPassword setFont:[UIFont systemFontOfSize:13]];
        [storedPassword setTextAlignment:NSTextAlignmentLeft];
        [contentView addSubview:storedPassword];

        
        // setup sensing info
        sensingTitle = [[UILabel alloc] initWithFrame:CGRectMake(8, storedPassword.frame.origin.y + storedPassword.frame.size.height + 12, bounds.width-16, 18)];
        [sensingTitle setText:@"Continuous Data Logging Mode"];
        [sensingTitle setTextColor:greenColor];
        [sensingTitle setBackgroundColor:[UIColor clearColor]];
        [sensingTitle setFont:[UIFont systemFontOfSize:17]];
        [sensingTitle setTextAlignment:NSTextAlignmentCenter];
        [contentView addSubview:sensingTitle];
        

        sensingTextView =[[UITextView alloc] initWithFrame:CGRectMake(8,sensingTitle.frame.size.height + sensingTitle.frame.origin.y-4, bounds.width-16, 40)];
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
        
        resumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, sensingTextView.frame.origin.y + sensingTextView.frame.size.height, bounds.width-16, 15)];
        [resumeLabel setText:@"Sensors will resume in"];
        [resumeLabel setTextColor:[UIColor whiteColor]];
        [resumeLabel setBackgroundColor:[UIColor clearColor]];
        [resumeLabel setFont:[UIFont systemFontOfSize:13]];
        [resumeLabel setTextAlignment:NSTextAlignmentCenter];
        [contentView addSubview:resumeLabel];
        
        // setup pause button
        pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(bounds.width/2-55, resumeLabel.frame.origin.y + resumeLabel.frame.size.height + 5, 110, 110)];
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
        NSString *sensingIncludesTextViewString = @"<style>* {    font-family: \"Helvetica Neue\"; text-align:justify;</style>Mobile sensor data includes: motion sensors (gyroscope, accelerometer), activity info, position data and basic device info.  It does <span style=\"font-style: italic;\">not</span> include content or call logs from phone or txt messages (SMS), <span style=\"font-style: italic;\">nor</span> do we capture any audio or video with this app.";
        NSData *sensingIncludesData = [sensingIncludesTextViewString dataUsingEncoding:NSUnicodeStringEncoding];
        NSAttributedString *sensingIncludesAttributedString= [[NSAttributedString alloc] initWithData:sensingIncludesData options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
        sensingIncludesTextView =[[UITextView alloc] initWithFrame:CGRectMake(8,pauseButton.frame.size.height + pauseButton.frame.origin.y, bounds.width-16, 40)];
        sensingIncludesTextView.editable = NO;
        [sensingIncludesTextView setAttributedText:sensingIncludesAttributedString];
        [sensingIncludesTextView setTextColor:[UIColor whiteColor]];
        [sensingIncludesTextView setBackgroundColor:[UIColor clearColor]];
        [sensingIncludesTextView setTintColor:greenColor];
//        [sensingIncludesTextView setDataDetectorTypes:UIDataDetectorTypeAll];
//        [sensingIncludesTextView setFont:[UIFont systemFontOfSize:12]];
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
        
        NSString *livingLabTextViewString = @"<style>* {    font-family: \"Helvetica Neue\"; text-align:justify;</style>The <a href=\"http://livinglab.mit.edu/\">MIT bigdata Living Lab</a> is building scalable data management tools and applications that enable researchers at MIT to demo new approaches to collecting, combining and using data for good on campus.";
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
       
        faqTextView =[[UITextView alloc] initWithFrame:CGRectMake(8,faqTitle.frame.size.height + faqTitle.frame.origin.y, bounds.width-16, 80)];
        faqTextView.editable = NO;
        faqTextView.userInteractionEnabled = YES;
        [faqTextView setText:@"Support: getfit-livinglab@csail.mit.edu\nFAQ: http://livinglab.mit.edu/getfit-faq"];
        [faqTextView setTextColor:[UIColor whiteColor]];
        [faqTextView setBackgroundColor:[UIColor clearColor]];
        [faqTextView setTintColor:greenColor];
        [faqTextView setDataDetectorTypes:UIDataDetectorTypeLink];
        [faqTextView setFont:[UIFont systemFontOfSize:12]];
        [faqTextView setTextAlignment:NSTextAlignmentCenter];
        [contentView addSubview:faqTextView];
        
        
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) viewWillAppear:(BOOL)animated{
    [self adjustResumeLabelText];
}

#pragma mark - Picker
- (void) addPicker:(id)sender {
    
    // default the date to the first item in the index
    NSNumber *minutes = [[pauseArr objectAtIndex:0] objectAtIndex:1];
    NSInteger intMins = [minutes integerValue];
    NSDate *resumeDate = [[NSDate date] dateByAddingTimeInterval:intMins*60];
    [defaults setObject:resumeDate forKey:@"resumeSensorDate"];
    [defaults synchronize];
    
    // adjust the label accordingly
    [self adjustResumeLabelText];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    [self.view insertSubview:pickerParentView aboveSubview:self.view];
    [UIView commitAnimations];
}

- (void) dismissPicker:(id)sender {
    // make sure to capture the input
    //    NSNumber *minutes = [[pauseArr objectAtIndex:row] objectAtIndex:1];
    
    // dismiss the picker
    [UIView beginAnimations:@"MoveOut" context:nil];
    [pickerParentView removeFromSuperview];
    [UIView commitAnimations];
}

# pragma mark
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [pauseArr count];
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

# pragma mark

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[pauseArr objectAtIndex:row] objectAtIndex:0];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    
    NSString *title = @"";
    
    title = [[pauseArr objectAtIndex:row] objectAtIndex:0];
    
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:kFONT_NAME}];
    
    return attString;
}

#pragma mark

- (void) pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    NSNumber *minutes = [[pauseArr objectAtIndex:row] objectAtIndex:1];
    NSDate *resumeDate;
    
    /// 999 means do not resume
    if ([minutes isEqualToNumber:@999]) {
        resumeDate = [NSDate distantFuture];
    } else {
        NSInteger intMins = [minutes integerValue];
        resumeDate = [[NSDate date] dateByAddingTimeInterval:intMins*60];
    }
    
    
    [defaults setObject:resumeDate forKey:@"resumeSensorDate"];
    [defaults synchronize];
    [self adjustResumeLabelText];
}

# pragma mark

// adjust the label informing the user of when data collection will resume
- (void) adjustResumeLabelText {
    //
    NSDate *pauseUntil = [defaults objectForKey:@"resumeSensorDate"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, hh:mm a"];
    NSString *dateString = [dateFormatter stringFromDate:pauseUntil];
    
    NSString *bodyStr;
    if (pauseUntil !=nil && [pauseUntil compare:[NSDate date]] == NSOrderedAscending) {
        bodyStr = @"Sensors currently enabled.";
        [pauseButton setTitle:kPAUSE_TITLE forState:UIControlStateNormal];
    } else if ([pauseUntil compare:[NSDate distantFuture]] == NSOrderedSame) {
        bodyStr = @"Sensor collection currently disabled forever.";
        [pauseButton setTitle:kRESUME_TITLE forState:UIControlStateNormal];
    } else {
        bodyStr = [NSString stringWithFormat:@"Sensors resuming on %@", dateString];
        [pauseButton setTitle:kRESUME_TITLE forState:UIControlStateNormal];
    }
    
    // label
    [resumeLabel setText:bodyStr];
}

# pragma mark - button and image resizing

//generate a new image of a different size
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

#pragma mark - Switch
- (void)appSwitchChanged:(id)sender {
    // change the defaults determining whether or not to post to getfit
    if (appSwitch.isOn) {
        [defaults setBool:YES forKey:@"postToGetFit"];
    } else {
        [defaults setBool:NO forKey:@"postToGetFit"];
    }
    [defaults synchronize];
}

@end
