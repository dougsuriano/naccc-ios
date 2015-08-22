//
//  DCBRacer.m
//  MlpsNaccc
//
//  Created by Doug Suriano on 8/17/14.
//
//

#import "DCBRacer.h"

@implementation DCBRacer

- (NSString *)displayName
{
    if ([self.nickName length] > 0) {
        return [NSString stringWithFormat:@"%@ %@ %@", self.firstName, self.nickName, self.lastName];
    }
    return [NSString stringWithFormat:@"%@ %@", self.firstName, self.lastName];
}

@end
