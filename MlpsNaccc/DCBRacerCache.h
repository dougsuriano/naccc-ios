//
//  DCBRacerCache.h
//  MlpsNaccc
//
//  Created by Doug Suriano on 8/17/14.
//
//

#import <Foundation/Foundation.h>

@class DCBRacer;

@protocol DCBRacerCache <NSObject>

- (DCBRacer *)cachedRacerOrNilForRacerNumber:(NSNumber *)racerNumber;
- (void)cacheRacer:(DCBRacer *)racer;

@end
