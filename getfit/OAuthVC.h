//
//  OAuthVC.h
//  GetFit
//
//  Created by Albert Carter on 12/5/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import <UIKit/UIKit.h>
@class MinuteTVC;

@protocol OAuthVCDelegate <NSObject>
@required
- (void) didDismissOAuthVCWithSuccessfulExtraction:(BOOL)success;
@end




@interface OAuthVC : UIViewController <UIWebViewDelegate, NSURLConnectionDelegate, UIAlertViewDelegate>


- (id) initWithDelegate:(UIViewController<OAuthVCDelegate> *)delegateVC;

@property (weak, nonatomic) MinuteTVC *minuteTVC;
@property (strong, atomic) UIViewController<OAuthVCDelegate> *delegate;

@end
