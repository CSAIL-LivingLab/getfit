//
//  IntroDetailVC.h
//  GetFit
//
//  Created by Albert Carter on 1/6/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroDetailVC_deprecated : UIViewController



@property (weak, nonatomic) IBOutlet UILabel *passwordStrLabel;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *passwordLabel;
@property (weak, nonatomic) IBOutlet UITextView *detailTextArea;
@property (weak, nonatomic) IBOutlet UIButton *getfitButton;

- (IBAction)getfitButtonClick:(id)sender;

@end
