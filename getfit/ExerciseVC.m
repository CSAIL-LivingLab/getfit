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

@implementation ExerciseVC


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"Timer";
//        UIImage *image = [UIImage imageNamed:@"Timer.png"];
//        self.tabBarItem.image = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // some useful varibales
    CGRect windowFrame = self.view.frame;
    CGFloat buttonWidth = 140;
    UIColor *systemBlue = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
    UIColor *systemBackground = [UIColor colorWithRed:.921568627 green:.941176471 blue:.945098039 alpha:1.0];
    
    _minuteEntry = [[MinuteEntry alloc] init];
    
    // make pickers
    _activityPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-250, self.view.bounds.size.width, 216)];
    _activityPicker.dataSource = self;
    _activityPicker.delegate = self;
    [_activityPicker setBackgroundColor:[UIColor whiteColor]];
    
    _intensityPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-250, self.view.bounds.size.width, 216)];
    _intensityPicker.dataSource = self;
    _intensityPicker.delegate = self;
    [_intensityPicker setBackgroundColor:[UIColor whiteColor]];
    [_intensityPicker reloadAllComponents];

    // tap the background to remove pickers
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPickers)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
    
    // make buttons
    _activityButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 75, buttonWidth, buttonWidth)];
    [_activityButton setTitle:@"-select action-" forState:UIControlStateNormal];
    [_activityButton setTitleColor:systemBlue forState:UIControlStateNormal];
    _activityButton.layer.cornerRadius = _activityButton.bounds.size.width/2;
    _activityButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _activityButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _activityButton.layer.borderWidth = 2.0;
    [_activityButton.layer setBorderColor:[systemBlue CGColor]];
    [_activityButton.layer setBackgroundColor:[systemBackground CGColor]];
    [_activityButton addTarget:self action:@selector(editAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:_activityButton];
    
    _intensityButton = [[UIButton alloc] initWithFrame:CGRectMake(windowFrame.size.width-10-buttonWidth, 75, buttonWidth, buttonWidth)];
    [ _intensityButton setTitle:@"-select intensity-" forState:UIControlStateNormal];
    [ _intensityButton setTitleColor:systemBlue forState:UIControlStateNormal];
    _intensityButton.layer.cornerRadius =  _intensityButton.bounds.size.width/2;
    _intensityButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _intensityButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _intensityButton.layer.borderWidth = 2.0;
    [_intensityButton addTarget:self action:@selector(editIntensity) forControlEvents:UIControlEventTouchUpInside];
    [_intensityButton.layer setBorderColor:[systemBlue CGColor]];
    [_intensityButton.layer setBackgroundColor:[systemBackground CGColor]];
    [self.view addSubview: _intensityButton];
    
    
    UIColor *redStuff = [UIColor colorWithRed:.88627451 green:.418039216 blue:.418039216 alpha:.2];
    _startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _startButton.frame = CGRectMake(windowFrame.size.width/2-buttonWidth/2, 375, buttonWidth, buttonWidth);
    [_startButton setTitle:@"Start" forState:UIControlStateNormal];
    [_startButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    _startButton.layer.borderWidth = 2.0;
    _startButton.layer.cornerRadius = _startButton.bounds.size.width/2;
    [_startButton.layer setBorderColor:[[UIColor redColor] CGColor]];
    [_startButton.layer setBackgroundColor:[redStuff CGColor]];
    [_startButton addTarget:self action:@selector(toggleRecording) forControlEvents:UIControlEventTouchUpInside];
    _startButton.alpha = 0.4;
     _startButton.userInteractionEnabled = NO;
    [self.view addSubview:_startButton];
    
    // make stopwatch
    _stopwatch = [[UILabel alloc] initWithFrame:CGRectMake(0, 238,  windowFrame.size.width, 125)];
    [_stopwatch setText:@"00:00.0"];
    _stopwatch.textAlignment = NSTextAlignmentCenter;
    _stopwatch.font = [UIFont fontWithName:@"Helvetica Light" size:90];
    [_stopwatch setBackgroundColor:[UIColor colorWithRed:.921568627 green:.941176471 blue:.945098039 alpha:1.0]];
    [self.view addSubview:_stopwatch];
    
    
}

- (void) viewWillAppear:(BOOL)animated {


}


- (void) dismissPickers {
    [UIView beginAnimations:@"MoveOut" context:nil];
    [_activityPicker removeFromSuperview];
    [_intensityPicker removeFromSuperview];
    [UIView commitAnimations];
    
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
    } else {
        [_startButton setTitle:@"Start" forState:UIControlStateNormal];
        
        [[OpenSense sharedInstance] stopCollector];
        [self saveMinuteEntry];

        // clear the pickers
        [ _activityButton setTitle:@"-select activity-" forState:UIControlStateNormal];
        [ _intensityButton setTitle:@"-select intensity-" forState:UIControlStateNormal];
        
        // reset the button
        [self activateRecordingButtonIfPossible];
    }
}

- (void) editAction {
    [UIView beginAnimations:@"MoveOut" context:nil];
    [_intensityPicker removeFromSuperview];
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    [self.view insertSubview:_activityPicker aboveSubview:self.view];
    [UIView commitAnimations];
    
}

- (void) editIntensity {
    [_activityPicker removeFromSuperview];
    [UIView commitAnimations];
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    [self.view insertSubview:_intensityPicker aboveSubview:self.view];
    [UIView commitAnimations];
}

- (void) activateRecordingButtonIfPossible {
    if (![_minuteEntry.activity isEqualToString:@""] && ![_minuteEntry.intensity isEqualToString:@""]) {
        _startButton.alpha = 1.0;
        _startButton.userInteractionEnabled = YES;
    } else {
        _startButton.alpha = 0.4;
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
    
    // add to the MinuteStore
    MinuteStore *ms = [MinuteStore sharedStore];
    [ms addMinuteEntry:_minuteEntry];
//    [ms postToDataHub];

    
//     stop gap: load the OAuthVC and have the user log in
    OAuthVC *oAuthVC = [[OAuthVC alloc]  init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:oAuthVC];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navController animated:YES completion:nil];
    // postToGetFit should be called after the user fills in their info. Right now, oAuthVC is calling it.
//    [ms postToGetFit];
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

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    Resources *resources = [Resources sharedResources];
    if (pickerView == _activityPicker) {
        return [resources.activities objectAtIndex:row];
    }
    
    return [resources.intensities objectAtIndex:row];
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    Resources *resources = [Resources sharedResources];
    
    if (pickerView == _activityPicker) {
        NSString *activity = [resources.activities objectAtIndex:row];
        [_activityButton setTitle:activity forState:UIControlStateNormal];
        _minuteEntry.activity = activity;
        
    } else {
        NSString *intensity = [resources.intensities objectAtIndex:row];
        [_intensityButton setTitle:intensity forState:UIControlStateNormal];
        _minuteEntry.intensity = intensity;
    }
    
    [self activateRecordingButtonIfPossible];
    
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
