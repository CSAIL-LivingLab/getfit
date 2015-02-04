 //
//  IntroVC.h
//  GetFit
//
//  Created by Albert Carter on 1/28/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>


@interface IntroVC : UIViewController <CLLocationManagerDelegate, UITextViewDelegate>

// method available so that it can be called by the introAuthorizationVC
- (void) loadFinalView;


@end
