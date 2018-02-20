//
//  AuthRequestModel.h
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "APIBaseModel.h"
#import "CCheckReportData.h"

@interface CCheckResponseModel : APIBaseModel

@property (nonatomic, readonly) long reportID;
@property (nonatomic, readonly) BOOL fakeCard;
@property (nonatomic, readonly) NSString *reportDate;
@property (nonatomic, readonly) NSArray<CCheckReportData*> *reports;

+ (instancetype)responseWithRawData:(NSDictionary *)data;

@end



