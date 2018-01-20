//
//  DevInit.m
//  CardCheck
//
//  Created by itnesPro on 12/29/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "InitializationData.h"

@interface InitializationData()

@property (nonatomic, readwrite) int attempts;
@property (nonatomic, readwrite) NSString *otp;

@property (nonatomic, strong) CardReaderData *readerData;
@property (nonatomic, strong) AuthResponseModel *authResponse;
@property (nonatomic, strong) InitResponseModel *initializationResponse;

@end

@implementation InitializationData

+ (instancetype)demoData
{
    InitializationData *data = [InitializationData new];
    [data setupWithCalculatedOtp: @"115181"];
    
    AuthRequestModel *authRequest = [AuthRequestModel new];
    [authRequest setupWithTime: 1515622537643];
    
    AuthResponseModel *authResponse = [AuthResponseModel new];
    [authResponse setupWithTime: 1515622539242];
    [authResponse setupWithRequest: authRequest];
    
    InitRequestModel *initRequest = [InitRequestModel new];
    [initRequest setupWithTime: 1515622587342];
    
    InitResponseModel *initResponse = [InitResponseModel new];
    [initResponse setupWithTime: 1515622587612];
    [initResponse setupWithRequest: initRequest];
    
    
    [data setupWithAuthResponse: authResponse];
    [data setupWithInitResponse: initResponse];
    
    return data;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.attempts = 3;
        self.readerData = [CardReaderData demoData];
    }
    return self;
}

- (void)setupWithCalculatedOtp:(NSString *)otp
{
    self.otp = otp;
}

- (void)setupWithAuthResponse:(AuthResponseModel *)response
{
    [self setAuthResponse: response];
}

- (void)setupWithInitResponse:(InitResponseModel *)response
{
    [self setInitializationResponse: response];
}

- (long)authRequestID {
    return self.authResponse.requestID;
}

- (long long)authRequestTime {
    return self.authResponse.request.time;
}

- (long long)authResponseTime {
    return self.authResponse.time;
}

- (long)appID {
    return self.initializationResponse.appID;
}

- (long long)devInitRequestTime {
    return self.initializationResponse.request.time;
}

- (long long)devInitResponseTime {
    return self.initializationResponse.time;
}

- (NSString *)customID {
    return self.readerData.customID;
}

- (NSString *)cipherAppKeys {
    return self.initializationResponse.appKeys;
}

- (NSString *)deviceInfo {
    return [[CurrentDevice sharedInstance] generalInfo];
}

#pragma mark - Debug

- (NSString *)currentClass {
    return CURRENT_CLASS;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@; \n otp = %i \n authRequestID = %li, \n authRequestTime = %lli, \n authResponseTime = %lli, \n devInitRequestTime = %lli, \n devInitResponseTime = %lli, \n appID = %li, \n appKeys = %@ \n\n", self, self.otp, self.authRequestID, self.authRequestTime, self.authResponseTime, self.devInitRequestTime, self.devInitResponseTime, self.appID, self.cipherAppKeys];
}


@end
