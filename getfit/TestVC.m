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
#import "DataHubCreation.h"

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

- (void) viewDidAppear:(BOOL)animated {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *email = [defaults stringForKey:@"email"];
    _emailLabel.text = email;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushOAuthVC:(id)sender {
    OAuthVC *oAuthVC = [[OAuthVC alloc]  init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:oAuthVC];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navController animated:YES completion:nil];
}

- (IBAction)testSave:(id)sender {
    MinuteStore *ms = [MinuteStore sharedStore];
    MinuteEntry *me = [ms createMinuteEntryWithActivity:@"foosball" intensity:@"low" duration:10 andEndTime:[NSDate date]];
    
    me.postedToDataHub = NO;
    me.postedToGetFit = YES;
    
    [ms removeMinuteEntryIfPostedToDataHubAndGetFit:me];

    [ms saveChanges];
}

- (IBAction)regexExtractionTest:(id)sender {
    
    DataHubCreation * dhCreation = [[DataHubCreation alloc] init];
    
    [dhCreation createDataHubUserFromEmail:@"arcarter@mit.edu" andUsername:@"al_carter" andPassword:@"389jk34"];

}

- (IBAction)postToDataHub:(id)sender {
    MinuteStore *ms = [MinuteStore sharedStore];
    [ms removeAllMinutes];
    
    MinuteEntry *me1 = [ms createMinuteEntryWithActivity:@"ptdh1" intensity:@"medium" duration:5 andEndTime:[NSDate date]];
    me1.postedToDataHub = YES;
    me1.postedToGetFit = YES;
    
    MinuteEntry *me2 = [ms createMinuteEntryWithActivity:@"ptdh2" intensity:@"medium" duration:10 andEndTime:[NSDate date]];
    me2.postedToDataHub = NO;
    me2.postedToDataHub = NO;
    
    MinuteEntry *me3 = [ms createMinuteEntryWithActivity:@"ptdh3" intensity:@"medium" duration:15 andEndTime:[NSDate date]];
    me3.postedToDataHub = YES;
    me3.postedToDataHub = NO;
    
    MinuteEntry *me4 = [ms createMinuteEntryWithActivity:@"ptdh4" intensity:@"medium" duration:20 andEndTime:[NSDate date]];
    me4.postedToDataHub = NO;
    me4.postedToGetFit = YES;
    
    MinuteEntry *me5 = [ms createMinuteEntryWithActivity:@"ptdh5" intensity:@"medium" duration:25 andEndTime:[NSDate date]];
    me5.postedToDataHub = YES;
    me5.postedToGetFit = YES;
    
//    BOOL *didPost = [ms postToDataHub];
    NSLog(@"\n\nPosted To DataHub: ");
//    NSLog(didPost ? @"YES" : @"NO");
}

- (IBAction)postToGetFitoAuth:(id)sender {
    MinuteStore *ms = [MinuteStore sharedStore];
    [ms removeAllMinutes];
    
    MinuteEntry *me1 = [ms createMinuteEntryWithActivity:@"ptdh1" intensity:@"medium" duration:5 andEndTime:[NSDate date]];
    me1.postedToDataHub = YES;
    me1.postedToGetFit = YES;
    
    MinuteEntry *me2 = [ms createMinuteEntryWithActivity:@"ptdh2" intensity:@"medium" duration:10 andEndTime:[NSDate date]];
    me2.postedToDataHub = NO;
    me2.postedToDataHub = NO;
    
    MinuteEntry *me3 = [ms createMinuteEntryWithActivity:@"ptdh3" intensity:@"medium" duration:15 andEndTime:[NSDate dateWithTimeIntervalSinceNow:-86400.0]];
    me3.postedToDataHub = YES;
    me3.postedToDataHub = NO;
    
    MinuteEntry *me4 = [ms createMinuteEntryWithActivity:@"ptdh4" intensity:@"medium" duration:20 andEndTime:[NSDate date]];
    me4.postedToDataHub = NO;
    me4.postedToGetFit = YES;
    
    MinuteEntry *me5 = [ms createMinuteEntryWithActivity:@"ptdh5" intensity:@"medium" duration:25 andEndTime:[NSDate date]];
    me5.postedToDataHub = YES;
    me5.postedToGetFit = YES;
    
    OAuthVC *oAuthVC = [[OAuthVC alloc]  init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:oAuthVC];
    navController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navController animated:YES completion:nil];
    
}

- (IBAction)postToGetFitNoAuth:(id)sender {
    MinuteStore *ms = [MinuteStore sharedStore];
    [ms removeAllMinutes];
    
    MinuteEntry *me1 = [ms createMinuteEntryWithActivity:@"ptdh1" intensity:@"medium" duration:5 andEndTime:[NSDate date]];
    me1.postedToDataHub = YES;
    me1.postedToGetFit = YES;
    
    MinuteEntry *me2 = [ms createMinuteEntryWithActivity:@"ptdh2" intensity:@"medium" duration:10 andEndTime:[NSDate dateWithTimeIntervalSinceNow:-86400.0]];
    me2.postedToDataHub = NO;
    me2.postedToDataHub = NO;
    
    MinuteEntry *me3 = [ms createMinuteEntryWithActivity:@"ptdh3" intensity:@"medium" duration:15 andEndTime:[NSDate date]];
    me3.postedToDataHub = YES;
    me3.postedToDataHub = NO;
    
    MinuteEntry *me4 = [ms createMinuteEntryWithActivity:@"ptdh4" intensity:@"medium" duration:20 andEndTime:[NSDate date]];
    me4.postedToDataHub = NO;
    me4.postedToGetFit = YES;
    
    MinuteEntry *me5 = [ms createMinuteEntryWithActivity:@"ptdh5" intensity:@"medium" duration:25 andEndTime:[NSDate date]];
    me5.postedToDataHub = YES;
    me5.postedToGetFit = YES;
    
//    BOOL *didPost = [ms postToGetFit];
    NSLog(@"\n\nPosted To GetFit No Auth: ");
//    NSLog(didPost ? @"YES" : @"NO");
}

- (IBAction)postToOpenSense:(id)sender {
    Resources *resources = [Resources sharedResources];
    [resources uploadOpenSenseData];
    
}

- (IBAction)deleteOpenSenseBatches:(id)sender {
    [[OpenSense sharedInstance] deleteAllBatches];
}

- (IBAction)previousOrCurrentMonday:(id)sender {
    // This is fucking infuriating. Why hasn't Apple figured out how to make date manipulation not totally suck?
    
//    Resources *resources = [Resources sharedResources];
//    NSDate *previousMonday = [resources previousMondayForDate:[NSDate date]];
    
    // this array is used to map days to their proper offsets
    // sunday = 1.
    // if 1, subtract 6 from the days, to find the past monday
    // the [0,0] is just in there for padding.
    NSArray *dayMapping = @[
          @[@0, @0],
          @[@1, @6],
          @[@2, @0],
          @[@3, @1],
          @[@4, @2],
          @[@5, @3],
          @[@6, @4],
          @[@7, @5]
          ];
    
    NSDate *today = [NSDate date];
    int currentDOW = [[[NSCalendar currentCalendar] components:NSWeekdayCalendarUnit fromDate:today] weekday];
    
    
    // get the date exactly 7 days ago (including timestamp stuff)
    NSNumber *numberOfDaysToSubtract = [[dayMapping objectAtIndex:currentDOW] objectAtIndex:1];
    NSTimeInterval timeIntervalToSubtract = -24*60*60*[numberOfDaysToSubtract intValue];
    NSDate *lastMondayWithTime = [today dateByAddingTimeInterval:timeIntervalToSubtract];
    
    
    // convert that to the time at midnight
    NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
    NSUInteger preservedComponents = (NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit);
    NSDate *lastMondayWithouTime = [calendar dateFromComponents:[calendar components:preservedComponents fromDate:lastMondayWithTime]];
    NSLog(@"%@", lastMondayWithouTime);

    
}

- (IBAction)startOpenSenseProbes:(id)sender {
    [[OpenSense sharedInstance] startCollector];
    
}

@end
