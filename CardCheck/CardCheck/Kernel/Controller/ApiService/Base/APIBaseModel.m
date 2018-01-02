//
//  APIBaseModel.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "APIBaseModel.h"

@interface APIBaseModel()

@property (nonatomic, readwrite) long long time;
@property (nonatomic, readwrite) NSString *signature;
@property (nonatomic, readwrite) APIBaseModel *request;

@end

@implementation APIBaseModel

- (instancetype)initWithRawData:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        
    }
    return self;
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

- (void)setupWithTime:(long long)time
{
    self.time = time;
}

- (BOOL)setupWithSignature:(NSNumber *)sign
{
    if (sign.intValue) {
        self.signature = [sign stringValue];
        return YES;
    }
    else {
        return NO;
    }
}

- (void)setupWithRequest:(APIBaseModel *)request {
    self.request = request;
}

#pragma mark - Errors
- (NSError *)failedInResponse:(NSString *)name withCode:(NSUInteger)code;
{
    NSError *err = [self errorWithCode: @(code) method: name reason: @"Bad request"];
    [self setupWithFailed: err];

    return err;
}

@end
