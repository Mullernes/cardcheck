//
//  DevInit.h
//  CardCheck
//
//  Created by itnesPro on 12/29/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "KLBaseModel.h"

@interface DevInitData : KLBaseModel

@property (nonatomic) NSUInteger calculatedOtp;
@property (nonatomic, readonly) NSUInteger requestID;
@property (nonatomic, readonly) NSUInteger requestTime;
@property (nonatomic, readonly) NSUInteger responseTime;

- (instancetype)initWithAuthResponse:(AuthResponseModel *)response;

@end
