//
//  DCBSimpleRacerCache.m
//  MlpsNaccc
//
//  Created by Doug Suriano on 8/17/14.
//
//

#import "DCBSimpleRacerCache.h"
#import "DCBRacer.h"

@interface DCBSimpleRacerCache ()

@property (nonatomic, strong) NSCache *racerCache;

@end

@implementation DCBSimpleRacerCache

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.racerCache = [[NSCache alloc] init];
    }
    return self;
}

- (DCBRacer *)cachedRacerOrNilForRacerNumber:(NSNumber *)racerNumber
{
    if ([self.racerCache objectForKey:racerNumber]) {
        return [self.racerCache objectForKey:racerNumber];
    }
    return nil;
}

- (void)cacheRacer:(DCBRacer *)racer
{
    [self.racerCache setObject:racer forKey:[racer racerNumber]];
}

@end
