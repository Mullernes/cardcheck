//
//  DevInit.h
//  CardCheck
//
//  Created by itnesPro on 12/29/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "KLBaseModel.h"
@class AuthResponseModel, InitResponseModel;

@interface InitializationData : KLBaseModel

@property (nonatomic, readonly) int otp;
@property (nonatomic, readonly) int attempts;

+ (instancetype)demoData;

- (void)setupWithCalculatedOtp:(int)otp;
- (void)setupWithAuthResponse:(AuthResponseModel *)response;
- (void)setupWithInitResponse:(InitResponseModel *)response;

- (long)authRequestID;
- (long long)authRequestTime;
- (long long)authResponseTime;

- (long)appID;
- (long long)devInitRequestTime;
- (long long)devInitResponseTime;

- (NSString *)customID;
- (NSString *)deviceInfo;
- (NSString *)cipherAppKeys;

@end
