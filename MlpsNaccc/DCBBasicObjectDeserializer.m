//
//  DCBBasicObjectDeserializer.m
//  MlpsNaccc
//
//  Created by Doug Suriano on 8/17/14.
//
//

#import "DCBBasicObjectDeserializer.h"
#import <DCKeyValueObjectMapping/DCKeyValueObjectMapping.h>
#import <DCKeyValueObjectMapping/DCParserConfiguration.h>
#import <DCKeyValueObjectMapping/DCObjectMapping.h>
#import "DCBCheckpoint.h"
#import "DCBRacer.h"

@implementation DCBBasicObjectDeserializer

- (NSArray *)deserializeCheckpoints:(NSArray *)checkpointDictionaries
{
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:[DCBCheckpoint class]];
    return [parser parseArray:checkpointDictionaries];
}

- (NSArray *)deserializeRacers:(NSArray *)racerDictionaries
{
    DCParserConfiguration *config = [DCParserConfiguration configuration];
    DCObjectMapping *pkMapping = [DCObjectMapping mapKeyPath:@"id" toAttribute:@"externalId" onClass:[DCBRacer class]];
    [config addObjectMapping:pkMapping];
    DCKeyValueObjectMapping *parser = [DCKeyValueObjectMapping mapperForClass:[DCBRacer class] andConfiguration:config];
    return [parser parseArray:racerDictionaries];
}

@end
