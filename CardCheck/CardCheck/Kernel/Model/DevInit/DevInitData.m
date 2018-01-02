//
//  DevInit.m
//  CardCheck
//
//  Created by itnesPro on 12/29/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "DevInitData.h"

@interface DevInitData()

@property (nonatomic, readwrite) int attempts;

@property (nonatomic, readwrite) long authRequestID;
@property (nonatomic, readwrite) long long authRequestTime;
@property (nonatomic, readwrite) long long authResponseTime;

@property (nonatomic, readwrite) long long devInitRequestTime;
@property (nonatomic, readwrite) long long devInitResponseTime;

@end

@implementation DevInitData

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.attempts = 3;
    }
    return self;
}

- (void)setupWithAuthResponse:(AuthResponseModel *)response
{
    self.authResponseTime = response.time;
    self.authRequestID = response.requestID;
    self.authRequestTime = response.request.time;
}

- (void)setupWithDevInitResponse:(DevInitResponseModel *)response
{
    self.devInitResponseTime = response.time;
    self.devInitRequestTime = response.request.time;
}

- (NSString *)deviceInfo {
    return [[CurrentDevice sharedInstance] generalInfo];
}

#pragma mark - Debug

- (NSString *)currentClass {
    return CURRENT_CLASS;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@; authRequestID = %li, authRequestTime = %lli, authResponseTime = %lli, devInitRequestTime = %lli, devInitResponseTime = %lli", self, self.authRequestID, self.authRequestTime, self.authResponseTime, self.devInitRequestTime, self.devInitResponseTime];
}


@end
