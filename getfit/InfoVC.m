//
//  AboutVC.m
//  GetFit
//
//  Created by Albert Carter on 12/17/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import "InfoVC.h"
#import "AboutView.h"
#import "OpenSense.h"

@interface InfoVC () {
    UIPickerView *pausePicker;
    NSArray *pauseArr;
}





@end

@implementation InfoVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"Info";
                UIImage *image = [UIImage imageNamed:@"info.png"];
                self.tabBarItem.image = image;
    }
    return self;
}

- (void) loadView {
    [super loadView];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    AboutView *aboutView = [[AboutView alloc] initWithFrame:frame];
    self.view = aboutView;
    [self addPauseButtonAndPicker];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) addPauseButtonAndPicker{
    
    CGSize size = self.view.bounds.size;
    
    //labels
    UIButton *pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 400, size.width, 30)];
    [pauseButton setTitle:@"Pause Collector" forState:UIControlStateNormal];
    pauseButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    [pauseButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [pauseButton addTarget:self action:@selector(pauseButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pauseButton];
    
    pausePicker= [[UIPickerView alloc] initWithFrame:CGRectMake(-1, self.view.bounds.size.height-250, self.view.bounds.size.width+2, 216)];
    pausePicker.dataSource = self;
    pausePicker.delegate = self;
//    [pausePicker setBackgroundColor:[UIColor blackColor]];
    [pausePicker reloadAllComponents];
    pausePicker.layer.borderColor = [UIColor lightGrayColor].CGColor;
    pausePicker.layer.borderWidth = 1;
    
    // remember to update pickerView didSelectRow if you update this array. Those values are hardcoded.
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
    
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPicker:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];

    
}


- (void) pauseButtonTouched:(id)sender {
    
    [UIView beginAnimations:@"MoveIn" context:nil];
    [self.view insertSubview:pausePicker aboveSubview:self.view];
    [UIView commitAnimations];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

# pragma mark - Picker

- (void) dismissPicker:(id)sender {
    [UIView beginAnimations:@"MoveOut" context:nil];
    [pausePicker removeFromSuperview];
    [UIView commitAnimations];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[pauseArr objectAtIndex:row] objectAtIndex:0];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [pauseArr count];
}

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:resumeDate forKey:@"resumeSensorDate"];
    [defaults synchronize];
    
}

    



@end
