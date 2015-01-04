//
//  GraphView.m
//  GetFit
//
//  Created by Albert Carter on 12/17/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView

- (id) initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentSize = CGSizeMake(self.bounds.size.width, 800);
        self.backgroundColor = [UIColor whiteColor];
        
        [self addGraphOne];
        [self addGraphTwo];
        [self addGraphThree];

        
    }
    return self;
}

- (void) addGraphOne {
    UIView *chartView = [[UIView alloc] initWithFrame:CGRectMake(15, 60, 320, 196)];
    
    UIImage *image = [UIImage imageNamed:@"chart_line.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];

    imageView.frame = chartView.bounds;
    
    [chartView addSubview:imageView];
    
    [self addSubview:chartView];
    
    
}

- (void) addGraphTwo {
    UIView *chartView = [[UIView alloc] initWithFrame:CGRectMake(15, 275, 320, 196)];
    
    UIImage *image = [UIImage imageNamed:@"chart_pie.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    imageView.frame = chartView.bounds;
    
    [chartView addSubview:imageView];
    
    [self addSubview:chartView];
}

- (void) addGraphThree {
    UIView *chartView = [[UIView alloc] initWithFrame:CGRectMake(15, 490, 320, 196)];
    
    UIImage *image = [UIImage imageNamed:@"chart_column.png"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    
    imageView.frame = chartView.bounds;
    
    [chartView addSubview:imageView];
    
    [self addSubview:chartView];
}




@end
