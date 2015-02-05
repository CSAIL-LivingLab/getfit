//
//  TestVC.h
//  GetFit
//
//  Created by Albert Carter on 1/12/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestVC : UIViewController
- (IBAction)pushOAuthVC:(id)sender;
- (IBAction)testSave:(id)sender;
- (IBAction)regexExtractionTest:(id)sender;
- (IBAction)postToDataHub:(id)sender;
- (IBAction)postToGetFitoAuth:(id)sender;
- (IBAction)postToGetFitNoAuth:(id)sender;
- (IBAction)postToOpenSense:(id)sender;
- (IBAction)deleteOpenSenseBatches:(id)sender;
- (IBAction)previousOrCurrentMonday:(id)sender;


@end
