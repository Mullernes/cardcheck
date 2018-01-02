//
//  AuthRequestModel.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "DevInitResponseModel.h"

@interface DevInitResponseModel()

@property (nonatomic, readwrite) int code;
@property (nonatomic, readwrite) long appID;
@property (nonatomic, readwrite) NSString *appKeys;

@end

@implementation DevInitResponseModel

+ (instancetype)responseWithRawData:(NSDictionary *)data
{
    return [[DevInitResponseModel alloc] initWithRawData: data.copy];
}

- (instancetype)initWithRawData:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        self.appKeys = [data objectForKey: @"app_keys"];
        self.code = [[data objectForKey: @"code"] intValue];
        self.appID = [[data objectForKey: @"app_id"] longValue];
        
        long long time = [[data objectForKey: @"time"] longLongValue];;
        [self setupWithTime: time];

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
             @"app_id"      :   @(self.appID),
             @"app_keys"    :   self.appKeys};
}

- (NSString *)debugDescription {
    if (self.isCorrect) {
        return [NSString stringWithFormat:@"self = %@; json = %@", self, self.parameters];
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
