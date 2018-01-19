//
//  AuthRequestModel.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "InitResponseModel.h"

@interface InitResponseModel()

@property (nonatomic, readwrite) int code;
@property (nonatomic, readwrite) long appID;
@property (nonatomic, readwrite) NSString *appKeys;

@end

@implementation InitResponseModel

+ (instancetype)responseWithRawData:(NSDictionary *)data
{
    return [[InitResponseModel alloc] initWithRawData: data.copy];
}

- (instancetype)initWithRawData:(NSDictionary *)data
{
    self = [super initWithRawData: data];
    if (self) {
        self.appKeys = [data kAppKeys];
        self.appID = [[data kAppID] longValue];
        self.code = [[data kResponseCode] intValue];

        if (self.code > 0) {
            [self failedInResponse: @"Dev_Initialization" withCode: self.code];
        }
        else if (!time || !self.appKeys || !self.appID) {
            [self failedInMethod: CURRENT_METHOD withReason: @"Invalid response - %@", data];
        }
    }
    return self;
}

- (NSString *)currentClass {
    return CURRENT_CLASS;
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
