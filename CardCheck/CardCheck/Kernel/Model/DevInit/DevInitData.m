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
@property (nonatomic) long long requestTime;
@property (nonatomic) long long responseTime;

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

#pragma mark - Debug

- (NSString *)currentClass {
    return CURRENT_CLASS;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@; requestID = %li, requestTime = %li, responseTime = %li", self, self.requestID, self.requestTime, self.responseTime];
}


@end
