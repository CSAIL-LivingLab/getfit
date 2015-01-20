//
//  AboutView.m
//  GetFit
//
//  Created by Albert Carter on 12/17/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import "InfoView.h"

@implementation InfoView

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addGetFitInfo];
        [self addDataHubInfo];
        [self addDataCollectionInfo];
        
    }
    return self;
}

- (void) addGetFitInfo {
    // our relationship with GetFit
    
    // title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 60, 320-40, 20)];
    [title setText:@"GetFit"];
    [title setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [title setNumberOfLines:0];
    [title sizeToFit];
    [self addSubview:title];
    
    // Body
    UILabel *body = [[UILabel alloc] initWithFrame:CGRectMake(20, 80, 320-40, 100)];
    [body setText:@"Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed."];
    [body setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [body setNumberOfLines:0];
    [body sizeToFit];
    [self addSubview:body];
    
}

- (void) addDataHubInfo {
    // our relationship with datahub
    
    // title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 160, 320-40, 20)];
    [title setText:@"DataHub"];
    [title setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [title setNumberOfLines:0];
    [title sizeToFit];
    [self addSubview:title];
    
    // Body
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    NSString *username = [defaults objectForKey:@"username"];
    NSString *password = [defaults objectForKey:@"password"];
    
    UILabel *body = [[UILabel alloc] initWithFrame:CGRectMake(20, 180, 320-40, 100)];
    NSString *bodyText = [NSString stringWithFormat:@"Sed ut perspiciatis unde omnis iste natus error sit voluptatem.\n\thttp://datahub.csail.mit.edu\n\tusername: %@\n\tpassword: %@", username, password];
    
    [body setText:bodyText];
    [body setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleBody]];
    [body setNumberOfLines:0];
    [body sizeToFit];
    [self addSubview:body];
    
}

- (void) addDataCollectionInfo {
    // title
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(20, 310, 320-40, 20)];
    [title setText:@"Pause Data Collection"];
    [title setFont:[UIFont preferredFontForTextStyle:UIFontTextStyleHeadline]];
    [title setNumberOfLines:0];
    [title sizeToFit];
    [self addSubview:title];
    
    // other text in infoVC
}


@end
