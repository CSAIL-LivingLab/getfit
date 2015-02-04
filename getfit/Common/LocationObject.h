//
//  Location.h
//  GetFit
//
//  Created by Albert Carter on 2/4/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationObject : NSObject <CLLocationManagerDelegate>


+ (instancetype) sharedLocationObject;

- (void) setupLocationManager;

@end
