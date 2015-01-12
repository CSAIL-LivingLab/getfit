//
//  TestVC.h
//  GetFit
//
//  Created by Albert Carter on 1/12/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestVC : UIViewController <NSURLConnectionDataDelegate>

- (IBAction)postToGetFit:(id)sender;
- (IBAction)loadOAuthVC:(id)sender;

@end
