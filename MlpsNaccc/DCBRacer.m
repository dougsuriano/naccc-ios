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
    if ([_nickName length] > 0) {
        return [NSString stringWithFormat:@"%@ %@ %@", _firstName, _nickName, _lastName];
    }
    return [NSString stringWithFormat:@"%@ %@", _firstName, _lastName];
}

@end
