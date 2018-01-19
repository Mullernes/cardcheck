//
//  AuthRequestModel.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "CFinishCheckResponseModel.h"

@interface CFinishCheckResponseModel()

@property (nonatomic, readwrite) int code;

@end

@implementation CFinishCheckResponseModel

+ (instancetype)responseWithRawData:(NSDictionary *)data
{
    return [[CFinishCheckResponseModel alloc] initWithRawData: data.copy];
}

- (instancetype)initWithRawData:(NSDictionary *)data
{
    self = [super initWithRawData: data];
    if (self) {
        self.code = [[data kResponseCode] intValue];
        
        if (self.code > 0) {
            [self failedInResponse: @"CFinishCheck_Response" withCode: self.code];
        }
        else if (!self.time) {
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

