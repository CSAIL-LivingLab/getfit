//
//  MinuteEntry.h
//  GetFit
//
//  Created by Albert Carter on 12/29/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MinuteEntry : NSObject


- (instancetype) initEntryWithActivity:(NSString *) activity
                             intensity:(NSString *)intensity
                              duration:(NSInteger)duration
                            andEndTime:(NSDate *)endTime;
- (BOOL) verifyEntry;

@property (weak, nonatomic) NSString *activity;
@property (weak, nonatomic) NSString *intensity;
@property NSInteger duration;
@property (strong, nonatomic) NSDate *endTime;



@end
