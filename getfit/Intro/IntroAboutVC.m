//
//  IntroAboutVC.m
//  GetFit
//
//  Created by Albert Carter on 1/6/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import "IntroAboutVC.h"
#import "IntroPageVC.h"

@interface IntroAboutVC ()
@property (weak, nonatomic) IntroPageVC *introPageVC;
@property BOOL ready;
@end

@implementation IntroAboutVC
@synthesize nameTextField, emailTextField, swipeToContinue, ready, introPageVC;

// hack so that it's possible to access the parent PageVC's array of pages

- (instancetype) initWithParentPageVC: (IntroPageVC *)parentPageVC {
    self = [super init];
    if (self) {
        self.introPageVC = parentPageVC;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    swipeToContinue.alpha = 0;
    swipeToContinue.hidden = NO;
    
    [nameTextField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    
    [emailTextField addTarget:self action:@selector(textChanged:) forControlEvents:UIControlEventEditingChanged];
    

    UITapGestureRecognizer* tapBackground = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    [tapBackground setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapBackground];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - helpers

- (void) checkForReady {
    if ([nameTextField.text length] > 0 && [self NSStringIsValidEmail:emailTextField.text] ) {
        ready = YES;
    }
    else {
        ready = NO;
    };
}


// should check for MIT email addresses.
-(BOOL) NSStringIsValidEmail:(NSString *)checkString
{
    BOOL stricterFilter = NO; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:checkString];
}

#pragma mark - change 

// fade in swipe button. Save user defaults accordingly.
- (void) textChanged:(UITextField *)textField{
    [self checkForReady];
    
    // if it's ready to go, add the detail view controller
    if (ready) {
        [introPageVC addIntroDetailVCToArr];
    }
    
    // fade in button
    if (ready && swipeToContinue.alpha < 1.0) {
        swipeToContinue.hidden = NO;
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseIn
                         animations:^{ swipeToContinue.alpha = 1;}
                         completion:nil];
        
    } else if (!ready && swipeToContinue.alpha > 0) {
        [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionCurveEaseOut
                         animations:^{ swipeToContinue.alpha = 0;}
                         completion:nil];
        swipeToContinue.hidden = YES;
    }
    
    // save defaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:nameTextField.text forKey:@"name"];
    [defaults setObject:emailTextField.text forKey:@"email"];
    [defaults synchronize];
}

#pragma mark - keyboard hiding/showing

- (void) textFieldDidBeginEditing:(UITextField *)textField {
    [self animateTextField:textField up:YES];
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    [self animateTextField:textField up:NO];
}

- (void) animateTextField: (UITextField *) textField up:(BOOL)up {
    const int movementDistance = 205; // try to match keyboard size
    const float movementDuration = 0.3f; // speed of movement
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
}

- (void)dismissKeyboard {
    [nameTextField resignFirstResponder];
    [emailTextField resignFirstResponder];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
