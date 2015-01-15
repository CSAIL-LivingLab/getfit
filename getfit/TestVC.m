//
//  TestVC.m
//  GetFit
//
//  Created by Albert Carter on 1/12/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//
// file is used to test code that will be used for [MinuteStore postToGetFit];

#import "OpenSense.h"
#import "TestVC.h"
#import "Resources.h"
#import "MinuteStore.h"
#import "Secret.h"
#import "MinuteEntry.h"
#import "OAuthVC.h"

@interface TestVC ()

@end

@implementation TestVC


- (instancetype) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"testing";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)dateMagic:(id)sender {
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *comps = [gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    int weekday = (int)[comps weekday];
    NSLog(@"the weekday %d",weekday);
    
    NSDate *lastSunday = [[NSDate date] dateByAddingTimeInterval:-3600*24*(weekday-1)];
    NSLog(@"lastSunday GMT: %@",lastSunday);
    
    [comps setHour:0];
    NSDate *sunday12am = [gregorian dateFromComponents:comps];
    NSLog(@"lastSunday GMT: %@",sunday12am);
    

}
@end
