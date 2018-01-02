//
//  DevInit.h
//  CardCheck
//
//  Created by itnesPro on 12/29/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "KLBaseModel.h"
@class AuthResponseModel, DevInitResponseModel;

@interface DevInitData : KLBaseModel

@property (nonatomic) NSUInteger calcOtp;
@property (nonatomic, readonly) int attempts;

@property (nonatomic, readonly) long authRequestID;
@property (nonatomic, readonly) long long authRequestTime;
@property (nonatomic, readonly) long long authResponseTime;

@property (nonatomic, readonly) long long devInitRequestTime;
@property (nonatomic, readonly) long long devInitResponseTime;

- (void)setupWithAuthResponse:(AuthResponseModel *)response;
- (void)setupWithDevInitResponse:(DevInitResponseModel *)response;

- (NSString *)deviceInfo;

@end
