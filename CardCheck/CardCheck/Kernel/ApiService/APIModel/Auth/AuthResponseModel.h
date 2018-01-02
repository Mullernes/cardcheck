//
//  AuthRequestModel.h
//  CardCheck
//
//  Created by itnesPro on 12/26/17.
//  Copyright © 2017 itnesPro. All rights reserved.
//

#import "APIBaseModel.h"

@interface AuthResponseModel : APIBaseModel

@property (nonatomic, readonly) long long time;
@property (nonatomic, readonly) NSUInteger code;
@property (nonatomic, readonly) NSUInteger requestID;

@property (nonatomic, strong, readonly) AuthRequestModel *request;

+ (instancetype)responseWithRawData:(NSDictionary *)data;
- (void)setupWithRequest:(AuthRequestModel *)request;

@end



