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

- (IBAction)firstSundayOfWeek:(id)sender {
    // today 12:00am
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute fromDate:[NSDate date]];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    NSDate *today12am = [calendar dateFromComponents:components];
    NSLog(@"today at 12am: %f", floor([today12am timeIntervalSince1970] * 1000));
    
    // day of week today
    NSDateFormatter *weekday = [[NSDateFormatter alloc] init];
    [weekday setDateFormat: @"EEEE"];
    NSLog(@"The day of the week is: %@", [weekday stringFromDate:today12am]);
    
    // sunday at 12:00am
    NSDate *previousSunday = [self previousSundayForDate:today12am];
    NSLog(@"previous sunday: %f", floor([previousSunday timeIntervalSince1970] * 1000));
    
}

-(NSDate *)previousSundayForDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    static NSUInteger SUNDAY = 1;
    static NSUInteger MONDAY = 2;
    
    NSDate *startOfWeek;
    [calendar rangeOfUnit:NSWeekCalendarUnit
            startDate:&startOfWeek
             interval:NULL
              forDate:date];
    
    if(calendar.firstWeekday == SUNDAY){
        
        NSDate *beginningOfDate;
        [calendar rangeOfUnit:NSDayCalendarUnit
                startDate:&beginningOfDate
                 interval:NULL forDate:date];
        if ([startOfWeek isEqualToDate:beginningOfDate]) {
            startOfWeek = [calendar dateByAddingComponents:(
                                                        {
                                                            NSDateComponents *comps = [[NSDateComponents alloc] init];
                                                            comps.day = -7;
                                                            comps;
                                                        })
                                                toDate:startOfWeek
                                               options:0];
        }
        return startOfWeek;
    }
    if(calendar.firstWeekday == MONDAY)
        return [calendar dateByAddingComponents:(
                                             {
                                                 NSDateComponents *comps = [[NSDateComponents alloc] init];
                                                 comps.day = -1;
                                                 comps;
                                             })
                                     toDate:startOfWeek
                                    options:0];
    
    return nil;
    
}


@end
