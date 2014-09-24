//
//  DCBObjectDeserialization.h
//  MlpsNaccc
//
//  Created by Doug Suriano on 8/17/14.
//
//

#import <Foundation/Foundation.h>

@protocol DCBObjectDeserialization <NSObject>

- (NSArray *)deserializeCheckpoints:(NSArray *)checkpointDictionaries;
- (NSArray *)deserializeRacers:(NSArray *)racerDictionaries;

@end
