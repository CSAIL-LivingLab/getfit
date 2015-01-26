//
//  IntroAboutVC.h
//  GetFit
//
//  Created by Albert Carter on 1/22/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

@class IntroPageVC;
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface IntroAboutVC : UIViewController < UIAlertViewDelegate, CLLocationManagerDelegate>

- (instancetype) initWithParentPageVC: (IntroPageVC *) parentPageVC;

- (IBAction)tapToContinue:(id)sender;
- (IBAction)donateChange:(id)sender;


@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UISwitch *donateSwitch;
@property (weak, nonatomic) IBOutlet UILabel *donateSensorLabel;
@property (weak, nonatomic) IBOutlet UILabel *noNetworkLabel;
@property (weak, nonatomic) IBOutlet UILabel *donateLabel;


@end
