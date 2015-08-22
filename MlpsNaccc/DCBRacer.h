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
@property (nonatomic, copy) NSString *firstName;
@property (nonatomic, copy) NSString *lastName;
@property (nonatomic, copy) NSString *nickName;
@property (nonatomic, copy) NSString *city;
@property (nonatomic, copy) NSString *gender;

- (NSString *)displayName;

@end
