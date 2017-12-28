//
//  APIBaseModel.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "APIBaseModel.h"

@interface APIBaseModel()
@end

@implementation APIBaseModel

+ (instancetype)responseWithRawData:(NSDictionary *)data
{
    return [APIBaseModel new];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.signature = @"";
    }
    return self;
}

#pragma mark - Working

- (NSData *)jsonData {
    return [[self parameters] JSONData];
}

- (NSString *)jsonString {
    return [[self parameters] JSONString];
}

- (NSDictionary *)parameters {
    return @{};
}

#pragma mark - Errors
- (NSError *)failedInResponse:(NSString *)name withCode:(NSUInteger)code;
{
    NSError *err = [self errorWithCode: @(code) method: name reason: @"Bad request"];
    [self setupWithFailed: err];

    return err;
}

@end
