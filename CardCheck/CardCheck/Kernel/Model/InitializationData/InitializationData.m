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
@property (nonatomic, readwrite) NSUInteger otp;

@property (nonatomic, strong) CardReaderData *readerData;
@property (nonatomic, strong) AuthResponseModel *authResponse;
@property (nonatomic, strong) InitResponseModel *initializationResponse;

@end

@implementation InitializationData

+ (instancetype)demoData
{
    InitializationData *data = [InitializationData new];
    [data setupWithCalculatedOtp: 124367];
    
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

- (void)setupWithCalculatedOtp:(NSUInteger)otp
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
    return [NSString stringWithFormat:@"%@; authRequestID = %li, authRequestTime = %lli, authResponseTime = %lli, devInitRequestTime = %lli, devInitResponseTime = %lli, appID = %li, appKeys = %@", self, self.authRequestID, self.authRequestTime, self.authResponseTime, self.devInitRequestTime, self.devInitResponseTime, self.appID, self.cipherAppKeys];
}


@end
