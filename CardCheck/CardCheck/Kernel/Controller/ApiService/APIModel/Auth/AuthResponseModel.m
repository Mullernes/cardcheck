//
//  AuthRequestModel.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "AuthResponseModel.h"

@interface AuthResponseModel()

@property (nonatomic, readwrite) int code;
@property (nonatomic, readwrite) long requestID;

@end

@implementation AuthResponseModel

+ (instancetype)responseWithRawData:(NSDictionary *)data
{
    return [[AuthResponseModel alloc] initWithRawData: data.copy];
}

- (instancetype)initWithRawData:(NSDictionary *)data
{
    self = [super initWithRawData: data];
    if (self) {
        self.code = [[data kResponseCode] intValue];
        self.requestID = [[data kRequestID] longValue];
        
        if (self.code > 0) {
            [self failedInResponse: @"User_Authorization" withCode: self.code];
        }
        else if (!time || !self.requestID) {
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
