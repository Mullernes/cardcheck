//
//  AesTrackData.h
//  CardCheck
//
//  Created by itnesPro on 1/9/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "APIBaseModel.h"

@interface CCheckReportData : APIBaseModel

- (instancetype)initWithRawData:(NSDictionary *)data;

@end
