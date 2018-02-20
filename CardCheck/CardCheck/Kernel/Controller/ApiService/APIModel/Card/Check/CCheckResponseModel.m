//
//  AuthRequestModel.m
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "CCheckResponseModel.h"

@interface CCheckResponseModel()

@property (nonatomic, readwrite) long reportID;
@property (nonatomic, readwrite) BOOL fakeCard;
@property (nonatomic, readwrite) NSString *reportDate;
@property (nonatomic, readwrite) NSArray<CCheckReportData*> *reports;

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
        self.reportID = [[data kReportID] longValue];
        self.fakeCard = [[data kFakeCard] boolValue];
        
        [self setupReports: [data kReportColumns]];
        
        if (self.code > 0) {
            [self failedInResponse: @"CCheck_Response" withCode: self.code];
        }
        else if (!self.time) {
            [self failedInMethod: CURRENT_METHOD withReason: @"Invalid response - %@", data];
        }
    }
    return self;
}

- (void)setupReports:(NSArray<NSDictionary*> *)data
{
    self.reports = @[];
    [data enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CCheckReportData *report = [[CCheckReportData alloc] initWithRawData: obj];
        if (report) {
            self.reports = [self.reports arrayByAddingObject: report];
        }
    }];
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

