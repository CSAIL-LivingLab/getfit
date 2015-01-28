//
//  AboutVC.h
//  GetFit
//
//  Created by Albert Carter on 1/23/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutVC : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>


// Getfit App
@property (weak, nonatomic) IBOutlet UILabel *appTitle;
@property (weak, nonatomic) IBOutlet UILabel *appLabel;

// Datahub
@property (weak, nonatomic) IBOutlet UILabel *datahubTitle;
@property (weak, nonatomic) IBOutlet UILabel *datahubLabel;
@property (weak, nonatomic) IBOutlet UILabel *credentialsLabel;

// OpenSense
@property (weak, nonatomic) IBOutlet UILabel *sensingTitle;
@property (weak, nonatomic) IBOutlet UILabel *sensingLabel;
@property (weak, nonatomic) IBOutlet UILabel *resumeLabel;

// OpenSense Button
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;

// LivingLab
@property (weak, nonatomic) IBOutlet UILabel *livingLabTitle;
@property (weak, nonatomic) IBOutlet UILabel *livingLabLabel;


@end
