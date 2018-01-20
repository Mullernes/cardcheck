//
//  AesTrackData.h
//  CardCheck
//
//  Created by itnesPro on 1/9/18.
//  Copyright © 2018 itnesPro. All rights reserved.
//

#import "APIBaseModel.h"

@interface CCheckReportData : APIBaseModel

@property (nonatomic, readonly) NSString *type;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *holderName;
@property (nonatomic, readonly) NSString *truncatedPan;
@property (nonatomic, readonly) NSArray<NSString*> *blacklists;

@property (nonatomic, readonly) NSString *issuerName;
@property (nonatomic, readonly) NSString *issuerCountry;

- (instancetype)initWithRawData:(NSDictionary *)data;

@end
