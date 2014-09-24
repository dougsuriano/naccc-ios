//
//  DCBAPIManager.h
//  MlpsNaccc
//
//  Created by Doug Suriano on 8/3/14.
//
//

#import "AFHTTPSessionManager.h"

@class DCBRacer;

@interface DCBAPIManager : AFHTTPSessionManager

+ (instancetype)sharedManager;
- (void)authorizedPing:(void (^)())success failure:(void (^)(NSError *error))failure;
- (void)obtainOAuthTokenWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(NSString *token))success failure:(void (^)(NSError *error))failure;
- (void)getListOfCheckpoints:(void (^)(NSArray *checkpoints))success failure:(void (^)(NSError *error))failure;
- (void)getRacerWithRacerNumber:(NSNumber *)racerNumber success:(void (^)(DCBRacer *racer))success failure:(void (^)(NSError *error))failure;
- (void)racerNumber:(NSNumber *)racerNumber pickupAtCheckpoint:(NSNumber *)checkpoint jobNumber:(NSNumber *)jobNumber success:(void (^)(NSString *confirmCode))success inputError:(void (^)(NSString *errorTitle, NSString *errorDescription))inputError failure:(void (^)(NSError *error))failure;
- (void)racerNumber:(NSNumber *)racerNumber dropOffAtCheckpoint:(NSNumber *)checkpoint confirmCode:(NSNumber *)confirmCode success:(void (^)())success inputError:(void (^)(NSString *errorTitle, NSString *errorDescription))inputError failure:(void (^)(NSError *error))failure;
- (void)logout;

@end
