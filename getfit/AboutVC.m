//
//  AboutVC.m
//  GetFit
//
//  Created by Albert Carter on 1/23/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import "AboutVC.h"

@interface AboutVC ()


@end

@implementation AboutVC {
    UIColor *blueColor;
    UIColor *greenColor;
    UIImage *pauseImage;
    
    UIView *pickerParentView;
    UIPickerView *pausePicker;
    UIButton *pausePickerDoneButton;
    NSArray *pauseArr;
    UILabel *pauseText;
    
    NSUserDefaults *defaults;

}


#define kFONT_NAME_BOLD @"HelveticaNeue-Bold"
#define kFONT_NAME @"HelveticaNeue-Light"

#define kPAUSE_TITLE @"pause\nsensors"
#define kRESUME_TITLE @"resume\nsensors"

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"About";
        UIImage *image = [UIImage imageNamed:@"info.png"];
        self.tabBarItem.image = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mainScrollView.translatesAutoresizingMaskIntoConstraints = NO;

    defaults = [NSUserDefaults standardUserDefaults];
    blueColor = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
    greenColor = [UIColor colorWithRed:.1 green:.8 blue:.1 alpha:1.0];
    
    // adjust the postToGetFIt switch for posting to getfit or not
    BOOL postToGetFit = [defaults boolForKey:@"postToGetFit"];
    if (postToGetFit) {
        [_appSwitch setOn:YES];
    } else {
        [_appSwitch setOn:NO];
    }
    
    //setup title labels colors
    [_appTitle setTextColor:greenColor];
    [_datahubTitle setTextColor:greenColor];
    [_sensingTitle setTextColor:greenColor];
    [_livingLabTitle setTextColor:greenColor];
    
    // setup credentialsLabel
    NSString *username = [defaults objectForKey:@"username"];
    NSString *password = [defaults objectForKey:@"password"];
    NSString *credentialsText = [NSString stringWithFormat:@"username: %@\npassword: %@", username, password];
    [_credentialsLabel setText:credentialsText];
    
    
    // setup the pauseButton
    [_pauseButton setTitle:kPAUSE_TITLE forState:UIControlStateNormal];
    _pauseButton.layer.cornerRadius = _pauseButton.bounds.size.width/2;
    _pauseButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _pauseButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _pauseButton.layer.borderWidth = 2.0;
    [_pauseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[_pauseButton titleLabel] setFont:[UIFont fontWithName:kFONT_NAME size:15]];
    [_pauseButton.layer setBackgroundColor:[blueColor CGColor]];
    [_pauseButton addTarget:self action:@selector(addPicker:) forControlEvents:UIControlEventTouchUpInside];
    [self adjustButtonForImage:_pauseButton];
    _pauseButton.titleLabel.numberOfLines = 2;
    _pauseButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    

    
    // setup the pause Array
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

}

- (void) viewWillAppear:(BOOL)animated {
    
    // setup content text
    
    NSString *appLabelHtmlString = @"<style>* {    font-family: \"Helvetica Neue\"; text-align:justify;</style>This app, created by the <a href=\"http://livinglab.mit.edu/\">MIT bigdata Living Lab</a>, allows users to record and log activity data for the <a href=\"https://getfit.mit.edu/\">getfit@mit</a> challenge. The app also allows users to record and submit this activity data to a Personal Data Store on CSAIL’s DataHub.";
    NSData *appLabelHtmlData = [appLabelHtmlString dataUsingEncoding:NSUnicodeStringEncoding];
    NSAttributedString *appLabelAttributedString= [[NSAttributedString alloc] initWithData:appLabelHtmlData options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    [_appLabel setScrollEnabled:NO];
    [_appLabel setEditable:NO];
    [_appLabel setAttributedText:appLabelAttributedString];
    [_appLabel setTextColor:[UIColor whiteColor]];
    [_appLabel sizeToFit];
    
    
    NSString *datahubLabelHtmlString = @"<style>* {    font-family: \"Helvetica Neue\"; text-align:justify;</style><a href=\"https://datahub.csail.mit.edu\">DataHub</a> (http://datahub.csail.mit.edu/) is a unified data management and collaboration platform under development at MIT CSAIL.";
    NSData *datahubLabelHtmlData = [datahubLabelHtmlString dataUsingEncoding:NSUnicodeStringEncoding];
    NSAttributedString *datahubLabelAttributedString= [[NSAttributedString alloc] initWithData:datahubLabelHtmlData options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType} documentAttributes:nil error:nil];
    [_datahubLabel setScrollEnabled:NO];
    [_datahubLabel setEditable:NO];
    [_datahubLabel setAttributedText:datahubLabelAttributedString];
    [_datahubLabel setTextColor:[UIColor whiteColor]];
    [_datahubLabel sizeToFit];
//    
//    [_datahubLabel setTintColor:greenColor];

    
    [_sensingLabel setScrollEnabled:NO];
    [_sensingLabel setEditable:NO];
    [_sensingLabel sizeToFit];
    
    [_livingLabLabel setScrollEnabled:NO];
    [_livingLabLabel setEditable:NO];
    [_livingLabLabel sizeToFit];
    _livingLabLabel.dataDetectorTypes = UIDataDetectorTypeLink;
    [_livingLabLabel setTintColor:greenColor];
    
    // inform the user of whether sensors are on or not
    [self adjustResumeLabelText];
}

- (void) viewDidAppear:(BOOL)animated {
    // setup the pickerView here, because the view sizes will be set.
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
}
#pragma mark - Switch
- (IBAction)appSwitchChanged:(id)sender {
    // change the defaults determining whether or not to post to getfit
    if (_appSwitch.isOn) {
        [defaults setBool:YES forKey:@"postToGetFit"];
    } else {
        [defaults setBool:NO forKey:@"postToGetFit"];
    }
    [defaults synchronize];
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
        [_pauseButton setTitle:kPAUSE_TITLE forState:UIControlStateNormal];
    } else if ([pauseUntil compare:[NSDate distantFuture]] == NSOrderedSame) {
        bodyStr = @"Sensor collection currently disabled forever.";
        [_pauseButton setTitle:kRESUME_TITLE forState:UIControlStateNormal];
    } else {
        bodyStr = [NSString stringWithFormat:@"Sensors resuming at %@", dateString];
        [_pauseButton setTitle:kRESUME_TITLE forState:UIControlStateNormal];
    }
    
    // label
    [_resumeLabel setText:bodyStr];
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

//fix up specified button so that title and image both show
-(void)adjustButtonForImage:(UIButton *)button {
    // the space between the image and text
    CGFloat spacing = 6.0;
    
    // lower the text and push it left so it appears centered
    //  below the image
    CGSize imageSize = button.imageView.image.size;
    button.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    // raise the image and push it right so it appears centered
    //  above the text
    CGSize titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
    
    button.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
}
@end
