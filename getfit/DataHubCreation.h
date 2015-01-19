//
//  DataHubCreation.h
//  GetFit
//
//  Created by Albert Carter on 1/18/15.
//  Copyright (c) 2015 MIT CSAIL Living Lab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataHubCreation : NSObject

//@property NSString *username;
//@property NSString *password;
//@property NSString *email;
@property NSString *appID;
@property NSString *appToken;

- (NSNumber *) createDataHubUserFromEmail:(NSString *)email andUsername:(NSString *)username andPassword:(NSString *) password;
- (BOOL) dropSchemaIfExistsForUser:(NSString *)username;
- (BOOL) createSchemaForUser:(NSString *)username;
- (NSString *) createUsernameFromEmail:(NSString *)email;
- (NSString *) createPassword;

- (NSString *) extractUsernameFromErrorStr:(NSString *)errStr;
- (NSString *) extractEmailFromErrorStr:(NSString *) errStr;

@end
