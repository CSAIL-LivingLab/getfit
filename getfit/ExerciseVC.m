//
//  ExerciseVC.m
//  GetFit
//
//  Created by Albert Carter on 12/31/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import "ExerciseVC.h"
#import "Resources.h"
#import "OAuthVC.h"
#import "AppDelegate.h"

#import "MinuteStore.h"
#import "MinuteEntry.h"

#import "OpenSense.h"


@interface ExerciseVC ()

@end


#define kFONT_NAME_BOLD @"HelveticaNeue-Bold"
#define kFONT_NAME @"HelveticaNeue-Light"

#define kACTIVITY_TITLE @"Select Activity"
#define kINTENSITY_TITLE @"Select Intensity"

@implementation ExerciseVC {
    UIColor *blueColor;
    UIColor *greenColor;
    UIColor *textColor;
    UIImage *activityImage;
    BOOL wasActive;
    
    BOOL exercising;
    MinuteEntry *minuteEntry;
    UILabel *stopwatch;
    NSTimeInterval startTime;
    
    UIButton *intensityButton;
    UIButton *activityButton;
    UIButton *startButton;
    UIButton *plusButton;

    UIView *activityPickerParentView;
    UIPickerView *activityPicker;
    
    UIView *intensityPickerParentView;
    UIPickerView *intensityPicker;
    
    UIButton *intensityDoneButton;
    UIButton *activityDoneButton;

}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"Logger";
        UIImage *image = [UIImage imageNamed:@"clock.png"];
        self.tabBarItem.image = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    blueColor = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
    greenColor = [UIColor colorWithRed:.1 green:.8 blue:.1 alpha:1.0];
    textColor =[UIColor colorWithRed:.921568627 green:.941176471 blue:.945098039 alpha:1.0];
    self.view.backgroundColor = [UIColor blackColor];
    
    // some useful varibales
    CGRect windowFrame = self.view.frame;
    CGFloat buttonWidth = 140;
    
    //UIColor *systemBackground = [UIColor colorWithRed:.921568627 green:.941176471 blue:.945098039 alpha:1.0];

    minuteEntry = [[MinuteEntry alloc] init];

    // make activity picker
    activityPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width+2, 216)];
    activityPicker.dataSource = self;
    activityPicker.delegate = self;
    [activityPicker setBackgroundColor:[UIColor blackColor]];
    [activityPicker reloadAllComponents];
    activityPicker.layer.borderColor = [UIColor lightGrayColor].CGColor;
    activityPicker.layer.borderWidth = 1;

    // make activity done button
    activityDoneButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50, 0, 50, 44)];
    [activityDoneButton setTitle:@"Done" forState:UIControlStateNormal];
    [activityDoneButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    [activityDoneButton.titleLabel setTextColor:[UIColor whiteColor]];
    [activityDoneButton addTarget:self action:@selector(dismissPickers) forControlEvents:UIControlEventTouchUpInside];
    [activityDoneButton setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPickers)];
    [activityDoneButton addGestureRecognizer:tap];

    // make activity picker parent view, and add subviews
    activityPickerParentView = [[UIView alloc] initWithFrame:CGRectMake(-1, self.view.bounds.size.height-250, self.view.bounds.size.width+2, 216)];
    [activityPickerParentView addSubview:activityPicker];
    [activityPickerParentView addSubview:activityDoneButton];
    
    
    // make intensity picker
    intensityPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width+2, 216)];
    intensityPicker.dataSource = self;
    intensityPicker.delegate = self;
    [intensityPicker setBackgroundColor:[UIColor blackColor]];
    [intensityPicker reloadAllComponents];
    intensityPicker.layer.borderColor = [UIColor lightGrayColor].CGColor;
    intensityPicker.layer.borderWidth = 1;
    
    // make intensity picker done button
    intensityDoneButton = [[UIButton alloc] initWithFrame:CGRectMake(self.view.frame.size.width-50, 0, 50, 44)];
    [intensityDoneButton setTitle:@"Done" forState:UIControlStateNormal];
    [intensityDoneButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    [intensityDoneButton.titleLabel setTextColor:[UIColor whiteColor]];
    [intensityDoneButton addTarget:self action:@selector(dismissPickers) forControlEvents:UIControlEventTouchUpInside];
    [intensityDoneButton setUserInteractionEnabled:YES];
    [intensityPicker addSubview:intensityDoneButton];
    
    // make intensity picker parent view, and add subviews
    intensityPickerParentView = [[UIView alloc] initWithFrame:CGRectMake(-1, self.view.bounds.size.height-250, self.view.bounds.size.width+2, 216)];
    [intensityPickerParentView addSubview:intensityPicker];
    [intensityPickerParentView addSubview:intensityDoneButton];

    
    // tap the background to remove pickers
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPickers)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
    
    
    
     // make buttons
    activityButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 175, buttonWidth, buttonWidth)];
    [activityButton setTitle:kACTIVITY_TITLE forState:UIControlStateNormal];
    activityButton.layer.cornerRadius = activityButton.bounds.size.width/2;
    activityButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    activityButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    activityButton.layer.borderWidth = 2.0;
    [activityButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[activityButton titleLabel] setFont:[UIFont fontWithName:kFONT_NAME size:16]];
    [activityButton.layer setBackgroundColor:[blueColor CGColor]];
    [activityButton addTarget:self action:@selector(editActivity) forControlEvents:UIControlEventTouchUpInside];
    CGSize s = [UIImage imageNamed:@"runner.png"].size;
    activityImage =[self imageWithImage:[UIImage imageNamed:@"runner.png"] scaledToSize:CGSizeMake(s.width/2.0, s.height/2.0)];
    [activityButton setImage:activityImage forState:UIControlStateNormal];
    [self adjustButtonForImage:activityButton];
    [self.view addSubview:activityButton];
    activityButton.titleLabel.numberOfLines = 2;
    activityButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    intensityButton = [[UIButton alloc] initWithFrame:CGRectMake(windowFrame.size.width-10-buttonWidth, 175, buttonWidth, buttonWidth)];
    [ intensityButton setTitle:kINTENSITY_TITLE forState:UIControlStateNormal];
    intensityButton.layer.cornerRadius =  intensityButton.bounds.size.width/2;
    intensityButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    intensityButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    intensityButton.layer.borderWidth = 2.0;
     s = [UIImage imageNamed:@"intensity.png"].size;
    UIImage *i =[self imageWithImage:[UIImage imageNamed:@"intensity.png"] scaledToSize:CGSizeMake(s.width/2.0, s.height/2.0)];
    [intensityButton setImage:i forState:UIControlStateNormal];
    [self adjustButtonForImage:intensityButton];
    intensityButton.titleLabel.numberOfLines = 2;
    intensityButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    

    [intensityButton addTarget:self action:@selector(editIntensity) forControlEvents:UIControlEventTouchUpInside];
    //[intensityButton.layer setBorderColor:[greenColor CGColor]];
    [intensityButton.layer setBackgroundColor:[greenColor CGColor]];
    [self.view addSubview: intensityButton];
    [[intensityButton titleLabel] setFont:[UIFont fontWithName:kFONT_NAME size:16]];
    [intensityButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    startButton = [UIButton buttonWithType:UIButtonTypeCustom];

    CGRect screen = [UIScreen mainScreen].bounds;
    
    if (screen.size.height == 480) { //4 or 4S {
        startButton.frame = CGRectMake(windowFrame.size.width/2-buttonWidth/2, 290, buttonWidth, buttonWidth);
        stopwatch = [[UILabel alloc] initWithFrame:CGRectMake(0, 190,  windowFrame.size.width, 125)];

    } else {
        startButton.frame = CGRectMake(windowFrame.size.width/2-buttonWidth/2, 375, buttonWidth, buttonWidth);
        stopwatch = [[UILabel alloc] initWithFrame:CGRectMake(0, 238,  windowFrame.size.width, 125)];
    }
    [startButton setTitle:@"Start" forState:UIControlStateNormal];
    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    startButton.layer.borderWidth = 2.0;
    startButton.layer.cornerRadius = startButton.bounds.size.width/2;
    //[startButton.layer setBorderColor:[[UIColor redColor] CGColor]];
    [startButton.layer setBackgroundColor:[[UIColor redColor] CGColor]];
    [startButton addTarget:self action:@selector(toggleRecording) forControlEvents:UIControlEventTouchUpInside];
     startButton.userInteractionEnabled = NO;
    [self.view addSubview:startButton];
    [[startButton titleLabel] setFont:[UIFont fontWithName:kFONT_NAME size:16]];

    // make stopwatch
    [stopwatch setText:@"00:00.0"];
    stopwatch.textAlignment = NSTextAlignmentCenter;
    stopwatch.font = [UIFont fontWithName:kFONT_NAME_BOLD size:90];
    [stopwatch setTextColor:textColor];
    stopwatch.backgroundColor = [UIColor clearColor];
    [self.view addSubview:stopwatch];
    
    startButton.hidden = YES;
    stopwatch.hidden = YES;
    
    // add plus button
    CGRect frame = [UIScreen mainScreen].bounds;
    CGRect rightFrame = CGRectMake(frame.size.width - 190, 10, 200, 40);
    plusButton = [[UIButton alloc] initWithFrame:rightFrame];
    [plusButton setTitle:@"manual entry +" forState:UIControlStateNormal];
    [plusButton setTitleColor:blueColor forState:UIControlStateNormal];
    AppDelegate *del = [[UIApplication sharedApplication] delegate];
    [plusButton addTarget:del action:@selector(pushMinuteVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:plusButton];
}


- (void) dismissPickers {
    [UIView beginAnimations:@"MoveOut" context:nil];
    [activityPickerParentView removeFromSuperview];
    [intensityPickerParentView removeFromSuperview];
    [UIView commitAnimations];
    [self activateRecordingButtonIfPossible];

    
}

#pragma mark - buttons


- (void) toggleRecording {
    [self dismissPickers];
    exercising = !exercising;
    
    if (exercising) {
        [startButton setTitle:@"Stop" forState:UIControlStateNormal];
         startTime = [NSDate timeIntervalSinceReferenceDate];
        [[OpenSense sharedInstance] startCollector];
        
        [self updateStopwatch];
        [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            intensityButton.backgroundColor = [UIColor clearColor];
            activityButton.backgroundColor = [UIColor clearColor];
            [plusButton setTitleColor:[UIColor clearColor] forState:UIControlStateNormal];
            stopwatch.textColor = textColor;
            startButton.backgroundColor = [UIColor redColor];


            [self offsetViews:@[stopwatch,startButton] byY:-100];
            [self offsetViews:@[intensityButton,activityButton] byY:100];


        }completion:^(BOOL done){
            //some completition
            intensityButton.hidden = TRUE;
            activityButton.hidden = TRUE;
            plusButton.hidden = TRUE;
        }];

    } else {
        [startButton setTitle:@"Start" forState:UIControlStateNormal];
        

        intensityButton.hidden = FALSE;
        activityButton.hidden = FALSE;
        plusButton.hidden = FALSE;
        stopwatch.hidden = YES;

        [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            intensityButton.backgroundColor = blueColor;
            activityButton.backgroundColor = greenColor;
            [plusButton setTitleColor:blueColor forState:UIControlStateNormal];
            
            [self offsetViews:@[stopwatch,startButton] byY:100];
            //[self offsetViews:@[intensityButton,activityButton] byY:-100];


            startButton.backgroundColor = [UIColor clearColor];
            [stopwatch setTextColor:[UIColor clearColor]];


        }completion:^(BOOL done){
            startButton.hidden = YES;
            wasActive = FALSE;
            //some completition
        }];

        
        [self saveMinuteEntry];

        // clear the pickers
        [ activityButton setTitle:kACTIVITY_TITLE forState:UIControlStateNormal];
        //[activityButton setImage:activityImage forState:UIControlStateNormal];
        [ intensityButton setTitle:kINTENSITY_TITLE forState:UIControlStateNormal];
        [self adjustButtonForImage:intensityButton];
        [self adjustButtonForImage:activityButton];

    }

}

- (void) editActivity {
    Resources *resources = [Resources sharedResources];
    
    // remove the intensityPicker if it was open
    [UIView beginAnimations:@"MoveOut" context:nil];
    [intensityPickerParentView removeFromSuperview];
    [UIView commitAnimations];
    
    // move in the activity picker
    [activityPicker reloadAllComponents];
    [UIView beginAnimations:@"MoveIn" context:nil];
    [self.view insertSubview:activityPickerParentView aboveSubview:self.view];
    [UIView commitAnimations];
    
    // set the activity button title
    NSString *title = [resources.activities objectAtIndex:[activityPicker selectedRowInComponent:0]];
    minuteEntry.activity = [resources.activities objectAtIndex:[activityPicker selectedRowInComponent:0]];
    [activityButton setTitle:title forState:UIControlStateNormal];
    [self adjustButtonForImage:activityButton];

}

- (void) editIntensity {
    Resources *resources = [Resources sharedResources];
    
    // remove the activityPicker if it was open
    [activityPickerParentView removeFromSuperview];
    [UIView commitAnimations];
    
    
    [intensityPicker reloadAllComponents];
    [UIView beginAnimations:@"MoveIn" context:nil];
    [self.view insertSubview:intensityPickerParentView aboveSubview:self.view];
    [UIView commitAnimations];
    
    NSString *title = [resources.intensities objectAtIndex:[intensityPicker selectedRowInComponent:0]];
    minuteEntry.intensity = [resources.intensities objectAtIndex:[intensityPicker selectedRowInComponent:0]];
    
    [intensityButton setTitle:title forState:UIControlStateNormal];
    [self adjustButtonForImage:intensityButton];

}

- (void) activateRecordingButtonIfPossible {
    
    if (![activityButton.titleLabel.text isEqualToString:kACTIVITY_TITLE]) {
        
        if (!wasActive) {
            wasActive = TRUE;
            startButton.backgroundColor = [UIColor clearColor];
            stopwatch.textColor = [UIColor clearColor];
            //stopwatch.layer.backgroundColor = [UIColor blackColor].CGColor;
            stopwatch.hidden = NO;
            startButton.hidden = NO;
            [UIView animateWithDuration:.25 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{

                [self offsetViews:@[intensityButton,activityButton] byY:-25];

            }completion:^(BOOL done){
                [UIView animateWithDuration:.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [self offsetViews:@[intensityButton,activityButton] byY:-75];

                    startButton.backgroundColor = [UIColor redColor];
                    //stopwatch.layer.backgroundColor = textColor.CGColor; //can't animate uilabel background color!
                    stopwatch.textColor = textColor;
                    
                }completion:^(BOOL done){
                    //some completition
                }];
            }];
            


            
            startButton.userInteractionEnabled = YES;
        }
    } else {
        if (wasActive) {
            wasActive = FALSE;
            [UIView animateWithDuration:1.0 delay:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                startButton.backgroundColor = [UIColor clearColor];
                stopwatch.textColor = [UIColor clearColor];

                // stopwatch.layer.backgroundColor = [UIColor blackColor].CGColor; //can't animate uilabel background color!
                [self offsetViews:@[intensityButton,activityButton] byY:100];

            }completion:^(BOOL done){
                stopwatch.hidden = YES;
                startButton.hidden = YES;

            }];

        }
        startButton.userInteractionEnabled = NO;
    }
}



# pragma mark - helper
- (void) updateStopwatch {
    if (!exercising) {
        stopwatch.text = @"00:00.0";
        return;
    };
    
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval elapsed = currentTime - startTime;
    
    int min = (int) (elapsed / 60.0);
    elapsed -= min * 60;
    int sec = (int) (elapsed);
    elapsed -= sec;
    int fraction = elapsed * 10;
    
    stopwatch.text = [NSString stringWithFormat:@"%02u:%02u.%u", min, sec, fraction];
    
    [self performSelector:@selector(updateStopwatch) withObject:self afterDelay:0.1];
}

// compute and save the duration
- (void) saveMinuteEntry {
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval elapsed = currentTime - startTime;
    int min = (int) (elapsed / 60.0);
    
    // save the EndTime
    minuteEntry.endTime = [NSDate date];
    minuteEntry.duration = min;
 
    // send OpenSense data to DataHub
    [[OpenSense sharedInstance] stopCollector];
    [[Resources sharedResources] uploadOpenSenseData];
 
    
    // add an alert asking the user whether they want to post to GetFit
    NSString *alertMessage = [NSString stringWithFormat:@"activity: %@\nintensity: %@\n duration: %d minutes.", minuteEntry.activity, minuteEntry.intensity, min];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([defaults boolForKey:@"postToGetFit"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save to GetFit?" message:alertMessage delegate:self cancelButtonTitle:@"cancel" otherButtonTitles:@"save", nil];
        [alert show];
    } else {
        minuteEntry.postedToGetFit = YES;
    }
    
    
    // add to the MinuteStore
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"Button Index %ld", (long)buttonIndex);
    
    // 0 is cancel
    if (buttonIndex == 0) {
        // set this up so that it will post to datahub, but not getfit
        minuteEntry.postedToDataHub = NO;
        minuteEntry.postedToGetFit = YES;
        minuteEntry.verified = NO;
    }
    
    MinuteStore *ms = [MinuteStore sharedStore];
    [ms addMinuteEntry:minuteEntry];
    
//     post minutes to DataHub
    [ms postToDataHub];
    
    // don't attempt to post to GetFit
    if (buttonIndex == 0) {
        return;
    }
    
    
    // only post right away if the user has allowed us to post to getfit
    // if the cookies are valid
    // and if tokens are valid
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // cookies and tokens are valid, and user is posting to getFit
    if ([defaults boolForKey:@"postToGetFit"] && [ms checkForValidCookies] && [ms checkForValidTokens:minuteEntry.endTime] ) {
        BOOL * success = [ms postToGetFit];
        
        
        if (success) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Minutes Saved" message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Getfit Error" message:@"Your minutes were not saved. Please make sure that you have filled out your getfit profile\n\n http://getfit.mit.edu/profile" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
            [alert show];
        }
        
    // user is posting to getFit, but doens't have valid tokens
    } else if ([defaults boolForKey:@"postToGetFit"]){
        // the oAuthVC will post the minutes
        OAuthVC *oAuthVC = [[OAuthVC alloc]  initWithDelegate:self];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:oAuthVC];
        navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:navController animated:YES completion:nil];
    } else {
        // set the minuteEntry.postedToGetFit to yes, because the user doesn't want postings, anyhow
        // this will make sure the minuteEntry is deletable later
        minuteEntry.postedToGetFit = YES;
    }
    
    // create a new minuteEntry, for next time the user posts
    minuteEntry = [[MinuteEntry alloc] init];
    
}

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
    
    if (titleSize.width > button.frame.size.width * .8 && ![button.titleLabel.text isEqualToString:kINTENSITY_TITLE]) {
        //insert newlines in label
        NSString *label = button.titleLabel.text;
        NSRange rOriginal = [label rangeOfString:@" "];
        if (NSNotFound != rOriginal.location) {
            label = [label stringByReplacingCharactersInRange: rOriginal withString:@"\n"];
        }
        [button setTitle:label forState:UIControlStateNormal];
        titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];

    }
    
    button.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
    
    
}

//move all views by specified y offset
-(void)offsetViews:(NSArray *)views byY:(int)yoff {
    for (UIView *v in views) {
        CGRect frame = v.frame;
        frame.origin.y += yoff;
        v.frame = frame;
    }
    
}


# pragma mark - picker

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    Resources *resources = [Resources sharedResources];
    
    if (pickerView == activityPicker) {
        return [resources.activities count];
    }
    
    return [resources.intensities count];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return  1;
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    Resources *resources = [Resources sharedResources];
    NSString *title = @"";
    if (pickerView == activityPicker) {
        title = [resources.activities objectAtIndex:row];
    } else {
        title = [resources.intensities objectAtIndex:row];
    }

    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:kFONT_NAME}];
    
    return attString;
    
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    Resources *resources = [Resources sharedResources];
    
    if (pickerView == activityPicker) {
        NSString *activity = [resources.activities objectAtIndex:row];
        [activityButton setTitle:activity forState:UIControlStateNormal];
        //[activityButton setImage:NULL forState:UIControlStateNormal];
        [self adjustButtonForImage:activityButton];
        minuteEntry.activity = activity;
        
    } else {
        NSString *intensity = [resources.intensities objectAtIndex:row];
        [intensityButton setTitle:intensity forState:UIControlStateNormal];
        [self adjustButtonForImage:intensityButton];

        minuteEntry.intensity = intensity;
    }
    
    //[self activateRecordingButtonIfPossible];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - OAuthVC Delegate

- (void) didDismissOAuthVCWithSuccessfulExtraction:(BOOL)success {
    if (success) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Minutes Saved" message:@"" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Getfit Error" message:@"Your minutes were not saved. Please make sure that you are a member of a getfit challenge team.\n\n http://getfit.mit.edu" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

@end
