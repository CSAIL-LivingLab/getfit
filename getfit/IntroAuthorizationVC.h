//
//  IntroAuthorizationVC.h
//  GetFit
//
//  Created by Albert Carter on 1/18/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import <UIKit/UIKit.h>
@class IntroAboutVC;

@interface IntroAuthorizationVC : UIViewController <UIWebViewDelegate>

@property (weak, nonatomic) IntroAboutVC *introAboutVC;

@end
