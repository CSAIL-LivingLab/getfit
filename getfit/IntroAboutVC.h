//
//  IntroAboutVC.h
//  GetFit
//
//  Created by Albert Carter on 1/22/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

@class IntroPageVC;
#import <UIKit/UIKit.h>

@interface IntroAboutVC : UIViewController <UITextFieldDelegate>

- (instancetype) initWithParentPageVC: (IntroPageVC *) parentPageVC;

- (IBAction)tapToContinue:(id)sender;

- (void) makeSchemaAndPushNextVC;


@property (weak, nonatomic) IBOutlet UIButton *continueButton;

@end
