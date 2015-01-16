//
//  AboutVC.m
//  GetFit
//
//  Created by Albert Carter on 12/17/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import "AboutVC.h"
#import "AboutView.h"

@interface AboutVC () {
    UISlider *slider;
}

@end

@implementation AboutVC

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

- (void) loadView {
    [super loadView];
    
    CGRect frame = [UIScreen mainScreen].bounds;
    AboutView *aboutView = [[AboutView alloc] initWithFrame:frame];
    self.view = aboutView;
    [self addSlider];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void) addSlider{
    
    //labels
    UILabel *minimum
    
    // Slider
    slider = [[UISlider alloc] initWithFrame:CGRectMake(20, 380, 320-40, 20)];
    [slider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) sliderDidChange:(id) sender{
    NSLog(@"slider value changed");
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
