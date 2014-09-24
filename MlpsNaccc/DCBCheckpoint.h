//
//  DCBCheckpoint.h
//  MlpsNaccc
//
//  Created by Doug Suriano on 8/3/14.
//
//

#import <Foundation/Foundation.h>

@interface DCBCheckpoint : NSObject

@property (nonatomic, strong) NSNumber *externalId;
@property (nonatomic, strong) NSNumber *checkpointNumber;
@property (nonatomic, strong) NSString *checkpointName;
@property (nonatomic, strong) NSString *notes;

@end
