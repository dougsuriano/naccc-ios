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
@property (nonatomic, copy) NSString *checkpointName;
@property (nonatomic, copy) NSString *notes;

@end
