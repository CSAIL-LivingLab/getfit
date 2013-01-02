//
//  OSProbe.h
//  OpenSense
//
//  Created by Mathias Hansen on 1/2/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OSProbeDelegate <NSObject>

- (void)probeDidStart;
- (void)probeDidStop;
- (void)sendData;
- (void)sendStatus;

@end

@interface OSProbe : NSObject

@property (nonatomic, assign) id<OSProbeDelegate> delegate;

+ (NSString*)name;
+ (NSString*)identifier;
+ (NSString*)description;

@end
