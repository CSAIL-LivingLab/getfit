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
    UIImage *pauseImage;
    
    UIPickerView *pausePicker;
    NSArray *pauseArr;
    UILabel *pauseText;

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

- (void) viewWillAppear:(BOOL)animated {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    blueColor = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
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
    
    
    // setup picker
    pausePicker= [[UIPickerView alloc] initWithFrame:CGRectMake(-1, self.view.bounds.size.height-250, self.view.bounds.size.width+2, 216)];
    pausePicker.dataSource = self;
    pausePicker.delegate = self;
    [pausePicker setBackgroundColor:[UIColor blackColor]];
    pausePicker.layer.borderColor = [UIColor lightGrayColor].CGColor;
    pausePicker.layer.borderWidth = 1;
    [pausePicker reloadAllComponents];
    
    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissPicker:)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
}

#pragma mark - Picker
- (void) addPicker:(id)sender {
    [UIView beginAnimations:@"MoveIn" context:nil];
    [self.view insertSubview:pausePicker aboveSubview:self.view];
    [UIView commitAnimations];
}

- (void) dismissPicker:(id)sender {
    [UIView beginAnimations:@"MoveOut" context:nil];
    [pausePicker removeFromSuperview];
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
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:resumeDate forKey:@"resumeSensorDate"];
    [defaults synchronize];
//    [self addPauseText];
    
}

#pragma mark - button and image resizing

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
