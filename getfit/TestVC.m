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
    BOOL *didPost = [ms postToDataHub];
    NSLog(didPost ? @"YES" : @"NO");
}

@end
