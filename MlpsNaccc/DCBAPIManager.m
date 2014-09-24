//
//  DCBAPIManager.m
//  MlpsNaccc
//
//  Created by Doug Suriano on 8/3/14.
//
//

#import <Lockbox/Lockbox.h>

#import "DCBAPIManager.h"
#import "DCBObjectDeserialization.h"
#import "DCBBasicObjectDeserializer.h"

#import "DCBRacerCache.h"
#import "DCBSimpleRacerCache.h"

#define kDCBBaseUrl      @"http://yogurthoagie.com/"
//#define kDCBBaseUrl      @"http://localhost:8000/"
#define kDCBClientId     @"253c66716ce3b197090a"
#define kDCBClientSecret @"b94c2b1516a240a781a86bf0afdb7d54b68b6e65"
#define kDCBGrantType    @"password"
#define kDCBTokenKey     @"token"

@interface DCBAPIManager ()

- (void)setOauthToken:(NSString *)token;

@property (nonatomic, strong) id<DCBObjectDeserialization>objectDeserialization;
@property (nonatomic, strong) id<DCBRacerCache>racerCache;

@end

@implementation DCBAPIManager

+ (instancetype)sharedManager
{
    static DCBAPIManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DCBAPIManager alloc] initWithBaseURL:[NSURL URLWithString:kDCBBaseUrl]];
        [manager setRequestSerializer:[AFJSONRequestSerializer serializer]];
        [manager setSecurityPolicy:[AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone]];
        [manager setObjectDeserialization:[[DCBBasicObjectDeserializer alloc] init]];
        [manager setRacerCache:[[DCBSimpleRacerCache alloc] init]];
        if ([Lockbox stringForKey:kDCBTokenKey]) {
            [manager setOauthToken:[Lockbox stringForKey:kDCBTokenKey]];
        }
    });
    return manager;
}

- (void)setOauthToken:(NSString *)token
{
    [[self requestSerializer] setValue:[NSString stringWithFormat:@"Bearer %@", token] forHTTPHeaderField:@"Authorization"];
}

- (void)authorizedPing:(void (^)())success failure:(void (^)(NSError *error))failure
{
    [self GET:@"/api/v1/ping/" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        success();
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

- (void)obtainOAuthTokenWithUsername:(NSString *)username password:(NSString *)password success:(void (^)(NSString *token))success failure:(void (^)(NSError *error))failure
{
    [self setRequestSerializer:[AFHTTPRequestSerializer serializer]];
    NSDictionary *params = @{@"client_id"       : kDCBClientId,
                             @"client_secret"   : kDCBClientSecret,
                             @"username"        : username,
                             @"password"        : password,
                             @"grant_type"      : kDCBGrantType
                             };
    
    [self POST:@"/oauth2/access_token/" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        [Lockbox setString:responseObject[@"access_token"] forKey:kDCBTokenKey];
        [self setRequestSerializer:[AFJSONRequestSerializer serializer]];
        [self setOauthToken:[Lockbox stringForKey:kDCBTokenKey]];
        success([Lockbox stringForKey:kDCBTokenKey]);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

- (void)getListOfCheckpoints:(void (^)(NSArray *checkpoints))success failure:(void (^)(NSError *error))failure
{
    [self GET:@"/api/v1/checkpoints/" parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *checkpoints = [_objectDeserialization deserializeCheckpoints:responseObject];
        success(checkpoints);
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

- (void)getRacerWithRacerNumber:(NSNumber *)racerNumber success:(void (^)(DCBRacer *racer))success failure:(void (^)(NSError *error))failure
{
    DCBRacer *racer = [_racerCache cachedRacerOrNilForRacerNumber:racerNumber];
    
    if (racer) {
        success(racer);
        return;
    }
    
    NSString *requestURL = [NSString stringWithFormat:@"/api/v1/racer/%@/", racerNumber];
    
    [self GET:requestURL parameters:nil success:^(NSURLSessionDataTask *task, id responseObject) {
        NSArray *racers = [_objectDeserialization deserializeRacers:@[responseObject]];
        if ([racers count] > 0) {
            DCBRacer *racer = racers[0];
            [_racerCache cacheRacer:racer];
            success(racer);
        }
        else {
            failure([[NSError alloc] init]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

- (void)racerNumber:(NSNumber *)racerNumber pickupAtCheckpoint:(NSNumber *)checkpoint jobNumber:(NSNumber *)jobNumber success:(void (^)(NSString *confirmCode))success inputError:(void (^)(NSString *errorTitle, NSString *errorDescription))inputError failure:(void (^)(NSError *error))failure
{
    NSDictionary *params = @{
                             @"racer_number" : racerNumber,
                             @"job_number" : jobNumber,
                             @"checkpoint" : checkpoint
                             };
    
    [self POST:@"/api/v1/pick/" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if (![responseObject[@"error"] boolValue]) {
            success([responseObject[@"confirm_code"] stringValue]);
        }
        else {
            inputError(responseObject[@"error_title"], responseObject[@"error_description"]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

- (void)racerNumber:(NSNumber *)racerNumber dropOffAtCheckpoint:(NSNumber *)checkpoint confirmCode:(NSNumber *)confirmCode success:(void (^)())success inputError:(void (^)(NSString *errorTitle, NSString *errorDescription))inputError failure:(void (^)(NSError *error))failure
{
    NSDictionary *params = @{
                             @"racer_number": racerNumber,
                             @"confirm_code" : confirmCode,
                             @"checkpoint" : checkpoint
                             };
    [self POST:@"/api/v1/drop/" parameters:params success:^(NSURLSessionDataTask *task, id responseObject) {
        if (![responseObject[@"error"] boolValue]) {
            success();
        }
        else {
            inputError(responseObject[@"error_title"], responseObject[@"error_description"]);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        failure(error);
    }];
}

- (void)logout
{
    [Lockbox setString:nil forKey:kDCBTokenKey];
}

@end
