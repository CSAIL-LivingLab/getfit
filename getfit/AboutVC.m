//
//  AboutVC.m
//  GetFit
//
//  Created by Albert Carter on 1/23/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import "AboutVC.h"

@interface AboutVC ()


@end

@implementation AboutVC {
    UIColor *blueColor;
    UIImage *pauseImage;
}


#define kFONT_NAME_BOLD @"HelveticaNeue-Bold"
#define kFONT_NAME @"HelveticaNeue-Light"

#define kPAUSE_TITLE @"pause\nsensors"
#define kRESUME_TITLE @"resume\nsensors"

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.tabBarItem.title = @"About";
        UIImage *image = [UIImage imageNamed:@"info.png"];
        self.tabBarItem.image = image;
    }
    return self;
}

- (void) viewWillAppear:(BOOL)animated {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    blueColor = [UIColor colorWithRed:0 green:0.478431 blue:1.0 alpha:1.0];
    
    // setup the pauseButton
    [_pauseButton setTitle:kPAUSE_TITLE forState:UIControlStateNormal];
    _pauseButton.layer.cornerRadius = _pauseButton.bounds.size.width/2;
    _pauseButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    _pauseButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    _pauseButton.layer.borderWidth = 2.0;
    [_pauseButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [[_pauseButton titleLabel] setFont:[UIFont fontWithName:kFONT_NAME size:13]];
    [_pauseButton.layer setBackgroundColor:[blueColor CGColor]];
    [_pauseButton addTarget:self action:@selector(pauseButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    CGSize s = [UIImage imageNamed:@"playpause.png"].size;
    pauseImage =[self imageWithImage:[UIImage imageNamed:@"playpause.png"] scaledToSize:CGSizeMake(s.width/2.0, s.height/2.0)];
    [_pauseButton setImage:pauseImage forState:UIControlStateNormal];
    [self adjustButtonForImage:_pauseButton];
    _pauseButton.titleLabel.numberOfLines = 2;
    _pauseButton.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//generate a new image of a different size
- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

//fix up specified button so that title and image both show
-(void)adjustButtonForImage:(UIButton *)button {
    // the space between the image and text
    CGFloat spacing = 6.0;
    
    // lower the text and push it left so it appears centered
    //  below the image
    CGSize imageSize = button.imageView.image.size;
    button.titleEdgeInsets = UIEdgeInsetsMake(0.0, - imageSize.width, - (imageSize.height + spacing), 0.0);
    
    // raise the image and push it right so it appears centered
    //  above the text
    CGSize titleSize = [button.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: button.titleLabel.font}];
    
    button.imageEdgeInsets = UIEdgeInsetsMake(- (titleSize.height + spacing), 0.0, 0.0, - titleSize.width);
}

@end
