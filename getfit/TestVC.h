//
//  TestVC.h
//  GetFit
//
//  Created by Albert Carter on 1/12/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestVC : UIViewController <OpenSenseDelegate>

- (IBAction)postToGetFit:(id)sender;
- (IBAction)loadOAuthVC:(id)sender;
- (IBAction)cookieMonster:(id)sender;
- (IBAction)fetchOpenSense:(id)sender;
- (IBAction)uploadOpenSense:(id)sender;

@end
