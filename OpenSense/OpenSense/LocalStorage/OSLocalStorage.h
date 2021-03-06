//
//  OSLocalStorage.h
//  OpenSense
//
//  Created by Mathias Hansen on 1/3/13.
//  Copyright (c) 2013 Mathias Hansen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSLocalStorage : NSObject {
    dispatch_queue_t probeFileQueue;
}

+ (OSLocalStorage*)sharedInstance;
- (void)saveBatch:(NSDictionary*)batch fromProbe:(NSString*)probeIdentifier;
- (void)fetchBatches:(void (^)(NSArray *batches))success;
- (void)fetchBatchesForProbe:(NSString*)probeIdentifier skipCurrent:(BOOL)skipCurrent parseJSON:(BOOL)parseJSON success:(void (^)(NSArray *batches))success;
- (BOOL)deleteAllBatches;
@end
