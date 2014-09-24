//
//  DCBRacer.h
//  MlpsNaccc
//
//  Created by Doug Suriano on 8/17/14.
//
//

#import <Foundation/Foundation.h>

@interface DCBRacer : NSObject

@property (nonatomic, strong) NSNumber *externalId;
@property (nonatomic, strong) NSNumber *racerNumber;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *gender;

- (NSString *)displayName;

@end
