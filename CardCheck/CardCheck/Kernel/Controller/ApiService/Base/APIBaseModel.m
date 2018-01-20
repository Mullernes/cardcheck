//
//  APIBaseModel.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "APIBaseModel.h"

@interface APIBaseModel()

@property (nonatomic, readwrite) int code;
@property (nonatomic, readwrite) long long time;
@property (nonatomic, readwrite) NSString *signature;
@property (nonatomic, readwrite) NSString *jsonString;
@property (nonatomic, readwrite) APIBaseModel *request;

@end

@implementation APIBaseModel

- (instancetype)initWithRawData:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        [self setJsonString: [data JSONString]];
        
        int code = [[data kResponseCode] intValue];
        [self setupWithCode: code];
        
        long long time = [[data kResponseTime] longLongValue];
        [self setupWithTime: time];
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

- (NSDictionary *)parameters {
    return [self.jsonString objectFromJSONString];
}

- (void)setupWithTime:(long long)time
{
    self.time = time;
}

- (void)setupWithCode:(int)code
{
    self.code = code;
}

- (BOOL)setupWithSignature:(NSString *)sign
{
    if ([sign length] == 6) {
        [self setSignature: sign];
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
- (NSError *)failedInResponse:(NSString *)name withCode:(NSInteger)code
{
    NSError *err = [self errorWithCode: code method: name reason: @"Bad request"];
    [self setupWithFailed: err];

    return err;
}

@end
