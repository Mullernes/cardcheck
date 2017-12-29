//
//  AuthRequestModel.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "AuthResponseModel.h"

@interface AuthResponseModel()

@property (nonatomic) NSUInteger code;
@property (nonatomic) NSUInteger time;
@property (nonatomic) NSUInteger requestID;

@end

@implementation AuthResponseModel

+ (instancetype)responseWithRawData:(NSDictionary *)data
{
    return [[AuthResponseModel alloc] initWithRawData: data.copy];
}

- (instancetype)initWithRawData:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        self.code = [[data objectForKey: @"code"] integerValue];
        self.time = [[data objectForKey: @"time"] integerValue];
        self.requestID = [[data objectForKey: @"auth_req_id"] integerValue];
        
        if (self.code > 0) {
            [self failedInResponse: @"User_Authentication" withCode: self.code];
        }
    }
    return self;
}

- (NSDictionary *)parameters
{
    return @{@"time"        :   @(self.time),
             @"code"        :   @(self.code),
             @"auth_req_id" :   @(self.requestID)};
}

- (NSString *)debugDescription {
    if (self.isCorrect) {
        return [NSString stringWithFormat:@"self = %@; json = %@", self, self.jsonString];
    }
    else if (self.failErr) {
        return self.failErr.debugDescription;
    }
    else if (self.warnErr) {
        return self.warnErr.debugDescription;
    }
    else {
        return @"undefined";
    }
}

@end
