//
//  IntroDetailVC.m
//  GetFit
//
//  Created by Albert Carter on 1/6/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import "IntroDetailVC.h"

@interface IntroDetailVC ()

@end

@implementation IntroDetailVC
@synthesize usernameLabel, passwordLabel, detailTextArea;

- (void)viewDidLoad {
    [super viewDidLoad];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    detailTextArea.text = @"Use it to view your data at \nhttps://datahub.csail.mit.edu.\n\nThere's no need to write it down. You can access it anytime from this app, or reset it online.";
    usernameLabel.text = [defaults objectForKey:@"username"];
    passwordLabel.text = [defaults objectForKey:@"password"];
    
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
