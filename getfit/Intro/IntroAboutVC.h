//
//  IntroAboutVC.h
//  GetFit
//
//  Created by Albert Carter on 1/6/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//
@class IntroPageVC;
#import <UIKit/UIKit.h>


@interface IntroAboutVC : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *tapToContinue;


- (instancetype) initWithParentPageVC: (IntroPageVC *) parentPageVC;
- (IBAction)tapToContinue:(id)sender;
- (void) makeSchemaAndPushNextVC;


@end
