//
//  Resources.h
//  GetFit
//
//  Created by Albert Carter on 12/31/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Resources : NSObject

+ (instancetype) sharedResources;

@property (strong, nonatomic) NSArray * activities;
@property (strong, nonatomic) NSArray * intensities;
@property (strong, nonatomic) NSArray * durations;

@end
