//
//  IntroPageVC.h
//  GetFit
//
//  Created by Albert Carter on 1/6/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroPageVC : UIPageViewController <UIPageViewControllerDataSource, UIPageViewControllerDelegate>

- (void) addIntroDetailVCToArr;
@end
