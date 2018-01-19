//
//  AuthRequestModel.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "CCheckResponseModel.h"

@interface CCheckResponseModel()

@property (nonatomic, readwrite) int code;
@property (nonatomic, readwrite) long reportID;
@property (nonatomic, readwrite) BOOL fakeCard;
@property (nonatomic, readwrite) NSString *reportDate;
@property (nonatomic, readwrite) CCheckReportData *report;

@end

@implementation CCheckResponseModel

+ (instancetype)responseWithRawData:(NSDictionary *)data
{
    return [[CCheckResponseModel alloc] initWithRawData: data.copy];
}

- (instancetype)initWithRawData:(NSDictionary *)data
{
    self = [super initWithRawData: data];
    if (self) {
        self.reportDate = [data kReportDate];
        self.code = [[data kResponseCode] intValue];
        self.reportID = [[data kReportID] longValue];
        self.fakeCard = [[data kFakeCard] boolValue];
        self.report = [[CCheckReportData alloc] initWithRawData: [[data kReportColumns] firstObject]];
        
        if (self.code > 0) {
            [self failedInResponse: @"CCheck_Response" withCode: self.code];
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

