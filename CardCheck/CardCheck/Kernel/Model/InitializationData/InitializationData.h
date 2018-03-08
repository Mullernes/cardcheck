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

@property (nonatomic, readonly) int attempts;
@property (nonatomic, readonly) NSString *otp;

+ (instancetype)demoData;

- (void)setupWithCalculatedOtp:(NSString *)otp;
- (void)setupWithAuthResponse:(AuthResponseModel *)response;
- (void)setupWithInitResponse:(InitResponseModel *)response;

- (BOOL)isValidTypedOTP:(NSString *)otp;

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
