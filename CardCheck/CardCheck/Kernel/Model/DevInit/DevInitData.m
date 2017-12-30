//
//  DevInit.m
//  CardCheck
//
//  Created by itnesPro on 12/29/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "DevInitData.h"

@interface DevInitData()

@property (nonatomic) NSUInteger requestID;
@property (nonatomic) NSUInteger requestTime;
@property (nonatomic) NSUInteger responseTime;

@end

@implementation DevInitData

- (instancetype)initWithAuthResponse:(AuthResponseModel *)response
{
    self = [super init];
    if (self) {
        self.responseTime = response.time;
        self.requestID = response.requestID;
        self.requestTime = response.request.time;
    }
    return self;
}

@end
