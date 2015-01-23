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

@property MinuteEntry *minuteEntry;

@property BOOL exercising;
@property UILabel *stopwatch;
@property NSTimeInterval startTime;

@property UIButton *intensityButton;
@property UIButton *activityButton;
@property UIButton *startButton;

@property UIPickerView *activityPicker;
@property UIPickerView *intensityPicker;


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

}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"Timer";
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
    
    // some useful varibales
    CGRect windowFrame = self.view.frame;
    CGFloat buttonWidth = 140;
    
    //UIColor *systemBackground = [UIColor colorWithRed:.921568627 green:.941176471 blue:.945098039 alpha:1.0];

    _minuteEntry = [[MinuteEntry alloc] init];

    // make pickers
    _activityPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(-1, self.view.bounds.size.height-250, self.view.bounds.size.width+2, 216)];
    _activityPicker.dataSource = self;
    _activityPicker.delegate = self;
    [_activityPicker setBackgroundColor:[UIColor blackColor]];
    [_activityPicker reloadAllComponents];
    _activityPicker.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _activityPicker.layer.borderWidth = 1;

    _intensityPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(-1, self.view.bounds.size.height-250, self.view.bounds.size.width+2, 216)];
    _intensityPicker.dataSource = self;
    _intensityPicker.delegate = self;
    [_intensityPicker setBackgroundColor:[UIColor blackColor]];
    [_intensityPicker reloadAllComponents];
    _intensityPicker.layer.borderColor = [UIColor lightGrayColor].CGColor;
    _intensityPicker.layer.borderWidth = 1;
    
    // tap the background to remove pickers
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPickers)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // make buttons
    _activityButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 175, buttonWidth, buttonWidth)];
    [_activityButton setTitle:kACTIVITY_TITLE forState:UIControlStateNormal];
    _activityButton.layer.cornerRadius = _activityButton.bounds.size.width/2;
    _activityButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _activityButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _activityButton.layer.borderWidth = 2.0;
    [_activityButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[_activityButton titleLabel] setFont:[UIFont fontWithName:kFONT_NAME size:16]];
    [_activityButton.layer setBackgroundColor:[blueColor CGColor]];
    [_activityButton addTarget:self action:@selector(editAction) forControlEvents:UIControlEventTouchUpInside];
    CGSize s = [UIImage imageNamed:@"runner.png"].size;
    activityImage =[self imageWithImage:[UIImage imageNamed:@"runner.png"] scaledToSize:CGSizeMake(s.width/2.0, s.height/2.0)];
    [_activityButton setImage:activityImage forState:UIControlStateNormal];
    [self adjustButtonForImage:_activityButton];
    [self.view addSubview:_activityButton];
    _activityButton.titleLabel.numberOfLines = 2;
    _activityButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    _intensityButton = [[UIButton alloc] initWithFrame:CGRectMake(windowFrame.size.width-10-buttonWidth, 175, buttonWidth, buttonWidth)];
    [ _intensityButton setTitle:kINTENSITY_TITLE forState:UIControlStateNormal];
    _intensityButton.layer.cornerRadius =  _intensityButton.bounds.size.width/2;
    _intensityButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _intensityButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _intensityButton.layer.borderWidth = 2.0;
     s = [UIImage imageNamed:@"intensity.png"].size;
    UIImage *i =[self imageWithImage:[UIImage imageNamed:@"intensity.png"] scaledToSize:CGSizeMake(s.width/2.0, s.height/2.0)];
    [_intensityButton setImage:i forState:UIControlStateNormal];
    [self adjustButtonForImage:_intensityButton];
    _intensityButton.titleLabel.numberOfLines = 2;
    _intensityButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    

    [_intensityButton addTarget:self action:@selector(editIntensity) forControlEvents:UIControlEventTouchUpInside];
    //[_intensityButton.layer setBorderColor:[greenColor CGColor]];
    [_intensityButton.layer setBackgroundColor:[greenColor CGColor]];
    [self.view addSubview: _intensityButton];
    [[_intensityButton titleLabel] setFont:[UIFont fontWithName:kFONT_NAME size:16]];
    [_intensityButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    _startButton = [UIButton buttonWithType:UIButtonTypeCustom];

    CGRect screen = [UIScreen mainScreen].bounds;
    
    if (screen.size.height == 480) { //4 or 4S {
        _startButton.frame = CGRectMake(windowFrame.size.width/2-buttonWidth/2, 290, buttonWidth, buttonWidth);
        _stopwatch = [[UILabel alloc] initWithFrame:CGRectMake(0, 190,  windowFrame.size.width, 125)];

    } else {
        _startButton.frame = CGRectMake(windowFrame.size.width/2-buttonWidth/2, 375, buttonWidth, buttonWidth);
        _stopwatch = [[UILabel alloc] initWithFrame:CGRectMake(0, 238,  windowFrame.size.width, 125)];
    }
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];
    [_startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _startButton.layer.borderWidth = 2.0;
    _startButton.layer.cornerRadius = _startButton.bounds.size.width/2;
    //[_startButton.layer setBorderColor:[[UIColor redColor] CGColor]];
    [_startButton.layer setBackgroundColor:[[UIColor redColor] CGColor]];
    [_startButton addTarget:self action:@selector(toggleRecording) forControlEvents:UIControlEventTouchUpInside];
     _startButton.userInteractionEnabled = NO;
    [self.view addSubview:_startButton];
    [[_startButton titleLabel] setFont:[UIFont fontWithName:kFONT_NAME size:16]];

    // make stopwatch
    [_stopwatch setText:@"00:00.0"];
    _stopwatch.textAlignment = NSTextAlignmentCenter;
    _stopwatch.font = [UIFont fontWithName:kFONT_NAME_BOLD size:90];
    [_stopwatch setTextColor:textColor];
    _stopwatch.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_stopwatch];
    
    _startButton.hidden = YES;
    _stopwatch.hidden = YES;
    
    // add plus button
    CGRect frame = [UIScreen mainScreen].bounds;
    CGRect rightFrame = CGRectMake(frame.size.width - 190, 10, 200, 40);
    UIButton *plusButton = [[UIButton alloc] initWithFrame:rightFrame];
    [plusButton setTitle:@"manual entry +" forState:UIControlStateNormal];
    [plusButton setTitleColor:[UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0] forState:UIControlStateNormal];
    AppDelegate *del = [[UIApplication sharedApplication] delegate];
    [plusButton addTarget:del action:@selector(pushMinuteVC) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:plusButton];
}



- (void) dismissPickers {
    [UIView beginAnimations:@"MoveOut" context:nil];
    [_activityPicker removeFromSuperview];
    [_intensityPicker removeFromSuperview];
    [UIView commitAnimations];
    [self activateRecordingButtonIfPossible];

    
}

#pragma mark - buttons


- (void) toggleRecording {
    [self dismissPickers];
    _exercising = !_exercising;
    
    if (_exercising) {
        [_startButton setTitle:@"Stop" forState:UIControlStateNormal];
         _startTime = [NSDate timeIntervalSinceReferenceDate];
        [[OpenSense sharedInstance] startCollector];
        
        [self updateStopwatch];
        [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _intensityButton.backgroundColor = [UIColor clearColor];
            _activityButton.backgroundColor = [UIColor clearColor];
            _stopwatch.textColor = textColor;
            _startButton.backgroundColor = [UIColor redColor];

            [self offsetViews:@[_stopwatch,_startButton] byY:-100];
            [self offsetViews:@[_intensityButton,_activityButton] byY:100];


        }completion:^(BOOL done){
            //some completition
            _intensityButton.hidden = TRUE;
            _activityButton.hidden = TRUE;
        }];

    } else {
        [_startButton setTitle:@"Start" forState:UIControlStateNormal];
        

        _intensityButton.hidden = FALSE;
        _activityButton.hidden = FALSE;
        _stopwatch.hidden = YES;

        [UIView animateWithDuration:1.0 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            _intensityButton.backgroundColor = blueColor;
            _activityButton.backgroundColor = greenColor;
            
            [self offsetViews:@[_stopwatch,_startButton] byY:100];
            //[self offsetViews:@[_intensityButton,_activityButton] byY:-100];


            _startButton.backgroundColor = [UIColor clearColor];
            [_stopwatch setTextColor:[UIColor clearColor]];


        }completion:^(BOOL done){
            _startButton.hidden = YES;
            wasActive = FALSE;
            //some completition
        }];

        
        [self saveMinuteEntry];

        // clear the pickers
        [ _activityButton setTitle:kACTIVITY_TITLE forState:UIControlStateNormal];
        //[_activityButton setImage:activityImage forState:UIControlStateNormal];
        [ _intensityButton setTitle:kINTENSITY_TITLE forState:UIControlStateNormal];
        [self adjustButtonForImage:_intensityButton];
        [self adjustButtonForImage:_activityButton];

    }

}

- (void) editAction {
    Resources *resources = [Resources sharedResources];

    [_activityPicker reloadAllComponents];
    [UIView beginAnimations:@"MoveOut" context:nil];
    [_intensityPicker removeFromSuperview];
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    [self.view insertSubview:_activityPicker aboveSubview:self.view];
    [UIView commitAnimations];
    NSString *title = [resources.activities objectAtIndex:[_activityPicker selectedRowInComponent:0]];
    self.minuteEntry.activity = [resources.activities objectAtIndex:[_activityPicker selectedRowInComponent:0]];

    [_activityButton setTitle:title forState:UIControlStateNormal];
    [self adjustButtonForImage:_activityButton];

}

- (void) editIntensity {
    Resources *resources = [Resources sharedResources];

    [_intensityPicker reloadAllComponents];
    [_activityPicker removeFromSuperview];
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    [self.view insertSubview:_intensityPicker aboveSubview:self.view];
    [UIView commitAnimations];
    
    NSString *title = [resources.intensities objectAtIndex:[_intensityPicker selectedRowInComponent:0]];
    self.minuteEntry.intensity = [resources.intensities objectAtIndex:[_intensityPicker selectedRowInComponent:0]];
    
    [_intensityButton setTitle:title forState:UIControlStateNormal];
    [self adjustButtonForImage:_intensityButton];

}

- (void) activateRecordingButtonIfPossible {
    
    if (![_activityButton.titleLabel.text isEqualToString:kACTIVITY_TITLE]) {
        
        if (!wasActive) {
            wasActive = TRUE;
            _startButton.backgroundColor = [UIColor clearColor];
            _stopwatch.textColor = [UIColor clearColor];
            //_stopwatch.layer.backgroundColor = [UIColor blackColor].CGColor;
            _stopwatch.hidden = NO;
            _startButton.hidden = NO;
            [UIView animateWithDuration:.25 delay:0.1 options:UIViewAnimationOptionCurveEaseIn animations:^{

                [self offsetViews:@[_intensityButton,_activityButton] byY:-25];

            }completion:^(BOOL done){
                [UIView animateWithDuration:.5 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                    [self offsetViews:@[_intensityButton,_activityButton] byY:-75];

                    _startButton.backgroundColor = [UIColor redColor];
                    //_stopwatch.layer.backgroundColor = textColor.CGColor; //can't animate uilabel background color!
                    _stopwatch.textColor = textColor;
                    
                }completion:^(BOOL done){
                    //some completition
                }];
            }];
            


            
            _startButton.userInteractionEnabled = YES;
        }
    } else {
        if (wasActive) {
            wasActive = FALSE;
            [UIView animateWithDuration:1.0 delay:0.5 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                _startButton.backgroundColor = [UIColor clearColor];
                _stopwatch.textColor = [UIColor clearColor];

                // _stopwatch.layer.backgroundColor = [UIColor blackColor].CGColor; //can't animate uilabel background color!
                [self offsetViews:@[_intensityButton,_activityButton] byY:100];

            }completion:^(BOOL done){
                _stopwatch.hidden = YES;
                _startButton.hidden = YES;

            }];

        }
        _startButton.userInteractionEnabled = NO;
    }
}



# pragma mark - helper
- (void) updateStopwatch {
    if (!_exercising) {
        _stopwatch.text = @"00:00.0";
        return;
    };
    
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval elapsed = currentTime - _startTime;
    
    int min = (int) (elapsed / 60.0);
    elapsed -= min * 60;
    int sec = (int) (elapsed);
    elapsed -= sec;
    int fraction = elapsed * 10;
    
    _stopwatch.text = [NSString stringWithFormat:@"%02u:%02u.%u", min, sec, fraction];
    
    [self performSelector:@selector(updateStopwatch) withObject:self afterDelay:0.1];
}

// compute and save the duration
- (void) saveMinuteEntry {
    NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval elapsed = currentTime - _startTime;
    int min = (int) (elapsed / 60.0);
    
    // save the EndTime
    _minuteEntry.endTime = [NSDate date];
    _minuteEntry.duration = min;
 
    // send OpenSense data to DataHub
    [[OpenSense sharedInstance] stopCollector];
    [[Resources sharedResources] uploadOpenSenseData];
 
    
    // add an alert asking the user whether they want to post to GetFit
    NSString *alertMessage = [NSString stringWithFormat:@"activity: %@\nintensity: %@\n duration: %d minutes.", _minuteEntry.activity, _minuteEntry.intensity, min];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Save to GetFit?" message:alertMessage delegate:self cancelButtonTitle:@"No" otherButtonTitles:@"Yes", nil];
    [alert show];
    
    // add to the MinuteStore
    }


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    NSLog(@"Button Index %ld", (long)buttonIndex);
    
    // 0 is cancel
    if (buttonIndex == 0) {
        // set this up so that it will post to datahub, but not getfit
        _minuteEntry.postedToDataHub = NO;
        _minuteEntry.postedToGetFit = YES;
        _minuteEntry.verified = NO;
    }
    
    MinuteStore *ms = [MinuteStore sharedStore];
    [ms addMinuteEntry:_minuteEntry];
    
//     post minutes to DataHub
    [ms postToDataHub];
    
    // don't attempt to post to GetFit
    if (buttonIndex == 0) {
        return;
    }
    
    if ([ms checkForValidCookies] && [ms checkForValidTokens:_minuteEntry.endTime] ) {
        [ms postToGetFit];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Minutes Saved" message:@"" delegate:nil cancelButtonTitle:@"ok" otherButtonTitles: nil];
        [alert show];
    } else{
        // the oAuthVC will post the minutes
        OAuthVC *oAuthVC = [[OAuthVC alloc]  init];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:oAuthVC];
        navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:navController animated:YES completion:nil];
    }

    
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

//move all views by specified yoff
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
    
    if (pickerView == _activityPicker) {
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
    if (pickerView == _activityPicker) {
        title = [resources.activities objectAtIndex:row];
    } else {
        title = [resources.intensities objectAtIndex:row];
    }

    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:kFONT_NAME}];
    
    return attString;
    
}


-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    Resources *resources = [Resources sharedResources];
    
    if (pickerView == _activityPicker) {
        NSString *activity = [resources.activities objectAtIndex:row];
        [_activityButton setTitle:activity forState:UIControlStateNormal];
        //[_activityButton setImage:NULL forState:UIControlStateNormal];
        [self adjustButtonForImage:_activityButton];
        _minuteEntry.activity = activity;
        
    } else {
        NSString *intensity = [resources.intensities objectAtIndex:row];
        [_intensityButton setTitle:intensity forState:UIControlStateNormal];
        [self adjustButtonForImage:_intensityButton];

        _minuteEntry.intensity = intensity;
    }
    
    //[self activateRecordingButtonIfPossible];
    
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
