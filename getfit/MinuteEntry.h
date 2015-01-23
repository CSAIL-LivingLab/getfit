//
//  MinuteEntry.h
//  GetFit
//
//  Created by Albert Carter on 12/29/14.
//  Copyright (c) 2014 CSAIL Big Data Initiative. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MinuteEntry : NSObject <NSCoding>


- (instancetype) initEntryWithActivity:(NSString *) activity
                             intensity:(NSString *)intensity
                              duration:(NSInteger)duration
                            andEndTime:(NSDate *)endTime;
- (BOOL) verifyEntry;
- (void) encodeWithCoder : (NSCoder *)aCoder ;
- (id) initWithCoder : (NSCoder *)aDecoder;

@property (strong, nonatomic) NSString *activity;
@property (strong, nonatomic) NSString *intensity;
@property NSInteger duration;
@property (strong, nonatomic) NSDate *endTime;
@property BOOL postedToGetFit;
@property BOOL postedToDataHub;
@property BOOL verified;




@end
